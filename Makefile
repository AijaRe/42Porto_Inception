# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: arepsa <arepsa@student.42porto.com>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/04/11 20:32:27 by arepsa            #+#    #+#              #
#    Updated: 2025/04/11 20:32:27 by arepsa           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOMAIN_NAME = arepsa.42.fr
WP_DATA = /home/arepsa/data/wordpress/
DB_DATA = /home/arepsa/data/mariadb/
ENV_FILE = /src/.env


all: build up

# Build images
build:
	docker compose build --no-cache

# Start containers in detached mode
up: create_dirs
	docker compose -f ./srcs/docker-compose.yml up -d

# Stop containers
down:
	docker compose -f ./srcs/docker-compose.yml down

# Remove containers and volumes
clean:
	docker compose -f ./srcs/docker-compose.yml down --volumes --remove-orphans

# Remove all images AND host data
fclean: clean
	docker rmi -f $$(docker images -qa)
	rm -rf ${WP_DATA} ${DB_DATA}
	@echo "All images and host data removed."

# Restart
re: down build up

# Create host directories if they don't exist and first make sure there is .env file
create_dirs:
	if (! test -f ${ENV_FILE}); then \
		echo "Error: please create a .env file"; \
		exit 1; \
	fi
	mkdir -p ${WP_DATA}
	mkdir -p ${DB_DATA}
	@echo "Data directories created."

up: build
	

	