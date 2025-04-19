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

COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = ./srcs/.env

# Load ennvironment variables from .env file
ifneq ($(wildcard ${ENV_FILE}),)
include ${ENV_FILE}
else
$(error Environment file not found. Please create it.)
endif

ifndef USER
$(error USER variable is not defined in $(ENV_FILE).)
endif

ifndef DOMAIN_NAME
$(error DOMAIN_NAME variable is not defined in $(ENV_FILE).)
endif

DOMAIN_NAME = ${DOMAIN_NAME}
WP_DATA = /home/${USER}/data/wordpress/
DB_DATA = /home/${USER}/data/mariadb/

all: build up

# Build images
build:
	docker compose -f ${COMPOSE_FILE} build --no-cache

# Start containers in detached mode
up: create_dirs
	docker compose -f ${COMPOSE_FILE} up -d

# Stop containers
down:
	docker compose -f ${COMPOSE_FILE} down

# Remove containers and volumes
clean: down
	@echo "Pruning Docker system (unused containers, networks, images, build cache)..."
	docker system prune -af

# Remove all images AND host data
fclean: clean create_dirs
	@echo "Removing host data directories..."
	sudo rm -rf ${WP_DATA} ${DB_DATA}
	@echo "All images and host data removed."

# Restart
re: down build up

# Create host directories if they don't exist and first make sure there is .env file
create_dirs:
	sudo mkdir -p ${WP_DATA}
	sudo mkdir -p ${DB_DATA}
	@echo "Data directories created."

maria:
	docker compose -f ${COMPOSE_FILE} up -d --no-deps --build mariadb

nginx:
	docker compose -f ${COMPOSE_FILE} up -d --no-deps --build nginx

wp:
	docker compose -f ${COMPOSE_FILE} up -d --no-deps --build wordpress

status:
	docker compose -f ${COMPOSE_FILE} ps
	docker image ls
	docker volume ls
	docker network ls

.PHONY: all build up down clean fclean re create_dirs
