#!/bin/bash
# Exit immediately if a command fails (exits with a non-zero status).
set -e

# Read secrets from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_pass)

# Check if initialized, install if not
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "INFO: Initializing MariaDB data directory..."
    chown -R mysql:mysql /var/lib/mysql # docker created directory as root, change permission to mysql
    chmod 700 /var/lib/mysql
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    echo "INFO: MariaDB initialization complete."
fi

service mariadb start;

sleep 5

if service mariadb status > /dev/null; then
	echo "INFO: MariaDB is running."
	echo "INFO: Creating database '${DB_NAME}' and user '${DB_USER}'..."
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
	mariadb -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';"
	mariadb -e "FLUSH PRIVILEGES;"
	echo "INFO: Database and user created successfully."

	echo "INFO: Shutting down temporary MariaDB server..."
	mysqladmin --user=root shutdown
else
	echo "ERROR: MariaDB failed to start."
	exit 1
fi

echo "INFO: Starting MariaDB server..."
# exec: Ensures that mysqld becomes the main process (PID 1)
exec "$@"
