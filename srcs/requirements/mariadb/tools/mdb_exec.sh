#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

service mariadb start;

sleep 5

echo "INFO: Creating database '$DB_NAME' and user '$DB_USER'..."
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"
echo "INFO: Database and user created successfully."

echo "INFO: Shutting down temporary MariaDB server..."
mysqladmin --user=root shutdown

echo "INFO: Starting MariaDB server..."
exec gosu mysql mysqld_safe
