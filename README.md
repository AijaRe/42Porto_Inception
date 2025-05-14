# Inception

This project, "Inception," sets up a small web server infrastructure using Docker and Docker Compose. The goal is to create a secure and robust multi-container environment running WordPress, accessible via a custom domain name (`your_login.42.fr`) over HTTPS.

## Useful maerials

*   [**Concepts Explained (Inception Project)**](https://medium.com/@imyzf/inception-3979046d90a0)
*   [**PID 1 and its role in Containers**](https://cloud.theodo.com/en/blog/docker-processes-container)
*   [**Using Secrets in Docker Compose (official documentation)**](https://docs.docker.com/compose/how-tos/use-secrets/)
*   [**Docker Best Practices for Building Images**](https://docs.docker.com/build/building/best-practices/)
*   [**Docker CLI Cheat Sheet (PDF)**](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
*   [**Install Docker Engine on Debian (official documentation)**](https://docs.docker.com/engine/install/debian/)


## Overview

The infrastructure consists of three main services, each running in its own dedicated Docker container built from custom Dockerfiles Debian as the base image (the only image that was allowed to pull from Dockerhub):

1.  **NGINX:** Serves as the public-facing web server and reverse proxy. It handles TLSv1.2 termination, ensuring all traffic to the WordPress site is encrypted. This is the sole entry point to the infrastructure, listening only on port 443.
2.  **WordPress:** Runs the WordPress application using PHP-FPM. It does not include its own web server (NGINX handles that).
3.  **MariaDB:** Provides the database backend for the WordPress installation.
3.  **Adminer (extra service):** Provides database visualization by accessing /adminer path.


## Key Features

*   **Dockerized Services:** Each service (NGINX, WordPress, MariaDB, Adminer) runs in an isolated container.
*   **Custom Dockerfiles:** All images are built from scratch using Dockerfiles, not pulled from public registries (except base OS images).
*   **Docker Compose:** Orchestrates the building and running of the multi-container application.
*   **TLS Security:** NGINX is configured for TLSv1.2, with port 443 as the only exposed port.
*   **Persistent Storage:** Docker volumes are used for the WordPress database and website files, ensuring data persistence across container restarts. These volumes are mapped to `/home/your_login/data/` on the host machine.
*   **Secure Configuration:** Passwords and sensitive information are managed using environment variables (via a `.env` file) and Docker secrets, not hardcoded into Dockerfiles.
*   **Custom Domain:** The WordPress site is accessible at `your_login.42.fr`, which resolves to your local IP.
*   **Automatic Restarts:** Containers are configured to restart automatically in case of a crash.
*   **Dedicated Network:** A custom Docker network facilitates communication between containers.
*   **Adminer (Optional):** An Adminer service is set up for easy database visualization and management.


## How to run the project
Firstly, you need to have Docker installed.

* **Secrets:** To run the project you mus create a folder called `secrets` at the root of the repository. The folder must contain three follwoing files (inside the .txt files just write the passwords, nothing else):
```
db_pass.txt
wp_admin_pass.txt
wp_user_pass.txt
```

* **.env:** Create `.env` file to store environment variables and place it in the `srcs` folder, the same level as docker compose file. The `.env` should contain following information (replace `xxxxx` with your information):

```
DOMAIN_NAME=xxxxx.42.fr
USER=xxxxx
DATA_PATH=/home/${USER}/data
# Set environment to noninteractive to avoid prompts during installation
DEBIAN_FRONTEND=noninteractive
# MYSQL SETUP
DB_HOST=mariadb # Service name in docker-compose
DB_NAME=inception
DB_USER=maria

# WORDPRESS SETUP
WP_URL=https://${DOMAIN_NAME}
WP_CONFIG_PATH=/var/www/html/wp-config.php
WP_CONTENT_DIR=/var/www/html/wp-content
WP_ADMIN_NAME=xxxxx
WP_ADMIN_EMAIL=xxxxx

WP_USER_NAME=xxxxx
WP_USER_EMAIL=xxxxx
WP_USER_ROLE=subscriber

WP_SITE_TITLE="inception"
WP_LANG=en_US
```

To point domain name to localhost, edit /etc/hosts add the redirection of 127.0.0.1 to the IP address you want (domain name), such as xxxxx.42.fr

Open terminal from the root and run `make`.

Now you can access youw wordpress website at https://xxxxx.42.fr

To check you database, access https://xxxxx.42.fr/adminer



## Directory Structure

The project follows a specific directory structure:
``` 
.
├── Makefile
├── secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs
    ├── .env
    ├── docker-compose.yml
    └── requirements
        ├── adminer
        │   └── Dockerfile
        │   ├── .dockerignore
        ├── mariadb
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf
        │   │   └── maria.cnf
        │   └── tools
        │       └── mdb_exec.sh
        ├── nginx
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf
        │   │   ├── nginx.conf
        │   │   └── server.conf
        └── wordpress
            ├── .dockerignore
            ├── Dockerfile
            ├── conf
            │   └── www.cnf
            └── tools
                └── wp_exec.sh
```
