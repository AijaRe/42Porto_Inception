# penultimate stable version in april 2025
FROM debian:bullseye-slim

# install MariaDB Server and 'gosu' to run entrypoint with mysql user
# use --no-install-recommends to keep the image smaller
RUN apt update && apt install -y --no-install-recommends \
    mariadb-server \
    gosu \
    # cleanup apt cache
    && apt clean \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mdb_exec.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mdb_exec.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mdb_exec.sh"]
