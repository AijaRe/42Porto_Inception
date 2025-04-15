#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "DEBUG: DB_NAME='${DB_NAME}'"
echo "DEBUG: DB_USER='${DB_USER}'"
# Check if initialized, install if not
if [ ! -d "${DATADIR}/mysql" ]; then
    echo "INFO: Initializing MariaDB data directory..."
    chown -R mysql:mysql "${DATADIR}"
    chmod 700 "${DATADIR}"
    mariadb-install-db --user=mysql --datadir="${DATADIR}"
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
exec gosu mysql mysqld
