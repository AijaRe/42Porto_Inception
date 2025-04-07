#!/bin/bash

# exit immediately if a command exits with a non-zero status.
set -e

# function to wait for the database connection
wait_for_db() {
    echo "Waiting for database connection at $DB_HOST..."
    local max_attempts=10
    local attempt=1
    
    while ! gosu www-data wp db check --quiet --path=/var/www/html --dbhost="$DB_HOST" --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" > /dev/null 2>&1; do
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
        --dbprefix="$DB_PREFIX" \
        --skip-check # skip DB check here as wait_for_db already did basic connectivity

    # generate and set WordPress salts/keys for security
    echo "Generating WordPress security salts..."
    gosu www-data wp config shuffle-salts --path=/var/www/html

    echo "WordPress configured."
else
    echo "wp-config.php found. Skipping configuration."
fi

# 2. ensure wp-content directory has correct permissions
echo "Ensuring correct permissions for $WP_CONTENT_DIR..."
chown -R www-data:www-data "$WP_CONTENT_DIR"
# set directory permissions to 755 and file permissions to 644 within wp-content
find "$WP_CONTENT_DIR" -type d -exec chmod 755 {} \;
find "$WP_CONTENT_DIR" -type f -exec chmod 644 {} \;
echo "Permissions set."


# 3. execute the main command (passed as arguments to this script)
echo "Starting PHP-FPM..."
# use exec to replace the script process with the CMD process (php-fpm)
# this ensures signals (like SIGTERM from 'docker stop') are passed correctly to php-fpm
exec "$@"
