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
ENV_FILE = ./src/.env

# Load ennvironment variables from .env file
ifneq ($(wildcard $(ENV_FILE)),)
    @echo "Loading environment variables from $(ENV_FILE)..."
    include $(ENV_FILE)
else
    @echo "Error: Environment file not found. Please create it."
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
clean:
	docker compose -f ${COMPOSE_FILE} down --volumes --remove-orphans

# Remove all images AND host data
fclean: clean
	@echo "Pruning Docker system (unused containers, networks, images, build cache)..."
	docker system prune -af
	@echo "Removing host data directories..."
	rm -rf ${WP_DATA} ${DB_DATA}
	@echo "All images and host data removed."

# Restart
re: down build up

# Create host directories if they don't exist and first make sure there is .env file
create_dirs:
	if (! test -f ${ENV_FILE}); then \
		echo "Error: Environment file not found. Please create it."; \
		exit 1; \
	fi
	mkdir -p ${WP_DATA}
	mkdir -p ${DB_DATA}
	@echo "Data directories created."

.PHONY all build up down clean fclean re create_dirs

	

	