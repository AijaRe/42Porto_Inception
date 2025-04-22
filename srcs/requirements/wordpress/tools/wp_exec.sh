#!/bin/bash

# exit immediately if a command exits with a non-zero status.
set -e

# Read secrets from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_pass)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_pass)
WP_USER_PASS=$(cat /run/secrets/wp_user_pass)

echo "DEBUG WP: DB_PASSWORD='${DB_PASSWORD}'"

# Check if the target directory is not empty or doesn't have core WP files
if ! [ -e "/var/www/html/wp-includes/version.php" ]; then
    echo "WordPress not found in /var/www/html - copying files..."
    # Use rsync to copy files and preserve attributes if possible
    # Using '.' ensures contents of source dir are copied into target dir
    rsync -a --chown=www-data:www-data /usr/src/wordpress/. /var/www/html/
    echo "WordPress files copied."
else
    echo "WordPress installation found in /var/www/html."
fi

# Set base permissions and ownership
echo "Ensuring base permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/
mkdir -p /var/www/html/wp-content/
find /var/www/html/wp-content -type d -exec chmod 755 {} \;
find /var/www/html/wp-content -type f -exec chmod 644 {} \;

# function to wait for the database connection
wait_for_db() {
    echo "Waiting for database connection at $DB_HOST..."
    local max_attempts=10
    local attempt=1
    echo "Using DB creds: host=$DB_HOST, user=$DB_USER, db=$DB_NAME"
    
    while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
        if [ $attempt -ge $max_attempts ]; then
            echo >&2 "Error: Database connection failed after $max_attempts attempts."
            exit 1
        fi
        echo "Database not ready. Retrying in 5 seconds... (Attempt $attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt + 1))
    done
    echo "Database connection successful!"
}

# 1. check if wp-config.php already exists
if [ ! -f "$WP_CONFIG_PATH" ]; then
    echo "wp-config.php not found. Configuring WordPress..."

    # wait for the database to be available
    wait_for_db

    # use wp-cli to create wp-config.php, run as www-data
    echo "Creating wp-config.php..."
    gosu www-data wp config create \
        --path=/var/www/html \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --skip-check # skip DB check, cause wait_for_db already did basic connectivity

    # generate and set WordPress salts/keys for security
    echo "Generating WordPress security salts..."
    gosu www-data wp config shuffle-salts --path=/var/www/html

    echo "WordPress configured."
else
    echo "wp-config.php found. Skipping configuration."
fi

# 2. install wordpress and create users
if ! gosu www-data wp core is-installed --path=/var/www/html; then
    echo "WordPress not installed in database. Running installation and user creation..."

    gosu www-data wp core install \
        --url="$WP_URL" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_NAME" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html
    echo "WordPress core installed."

    # Create a new user
    if ! gosu www-data wp user get "$WP_USER_NAME" --field=ID --path=/var/www/html 2>/dev/null; then
        gosu www-data wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
            --user_pass="$WP_USER_PASS" \
            --role="$WP_USER_ROLE" \
            --path=/var/www/html
        echo "Second user '$WP_USER_NAME' created."
    else
        echo "Second user '$WP_USER_NAME' already exists. Skipping creation."
    fi
fi


# 3. ensure wp-content directory has correct permissions
echo "Ensuring correct permissions for $WP_CONTENT_DIR..."
chown -R www-data:www-data "$WP_CONTENT_DIR"
# set directory permissions to 755 and file permissions to 644 within wp-content
find "$WP_CONTENT_DIR" -type d -exec chmod 755 {} \;
find "$WP_CONTENT_DIR" -type f -exec chmod 644 {} \;
echo "Permissions set."

# 4. execute the main command (passed as arguments to this script)
echo "Ensuring PHP-FPM run directory exists..."
mkdir -p /run/php
chown www-data:www-data /run/php
echo "Starting PHP-FPM..."
# use exec $@ to replace the script process with the CMD process (php-fpm)
# this ensures signals (like SIGTERM from 'docker stop') are passed correctly to php-fpm
exec "$@"
