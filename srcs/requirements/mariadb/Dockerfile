# penultimate stable version in april 2025
FROM debian:bullseye-slim

# install MariaDB Server and 'gosu' to run entrypoint with mysql user
# use --no-install-recommends to keep the image smaller
RUN apt update && apt install -y --no-install-recommends \
    mariadb-server \
    gosu \
    # cleanup apt cache
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY tools/mdb_exec.sh /bin/

RUN chmod +x /bin/mdb_exec.sh

EXPOSE 3306

# define the location of database data as a volume for data persistance
VOLUME /var/lib/mysql

ENTRYPOINT ["mdb_exec.sh"]
