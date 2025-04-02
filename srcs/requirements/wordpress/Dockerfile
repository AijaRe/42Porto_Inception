# penultimate stable version in april 2025
FROM debian:bullseye

# Set Wordpress version
ARG WP_VERSION=6.7.1
ARG WP_CLI_VERSION=2.11.0

# Set environment to noninteractive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
# wget - for downloading files (Wordpress and wp-cli)
# php-fpm - for running PHP applications
# php-mysql - for MySQL database connection
# mariadb-client - for wp-cli database management
RUN apt update && apt install -y --no-install-recommends \
	wget \
	php7.4-fpm \
	php7.4-mysql \
	mariadb-client \
	tar \
	# cleanup
	&& rm -rf /var/lib/apt/lists/*

# Download and extract Wordpress
RUN wget -q https://wordpress.org/wordpress-${WP_VERSION}.tar.gz \
	&& tar -xzf wordpress-${WP_VERSION}.tar.gz \
	&& rm wordpress-${WP_VERSION}.tar.gz \
	&& mv wordpress /var/www/html/ \
	&& chown -R www-data:www-data /var/www/html/ \
	&& chmod -R 755 /var/www/html/

# Download and install wp-cli
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp \
	&& mkdir -p /var/www/html/.wp-cli/cache/ \
	&& mkdir -p /var/www/html/wp-content/uploads/ \
	&& chown -R www-data:www-data /var/www/html/.wp-cli \
	&& chmod -R 755 /var/www/html/.wp-cli

# Configure PHP-FPM
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Set the working directory
WORKDIR /var/www/html

# Copy the entrypoint script and make it executable
COPY ./tools/wp_exec.sh /usr/local/bin/wp_exec.sh
RUN chmod +x /usr/local/bin/wp_exec.sh

EXPOSE 9000

# Set the entrypoint to the script
# Run php-fpm in foreground mode to prevent daemonizing 
ENTRYPOINT ["/usr/local/bin/wp_exec.sh", "php-fpm7.4", "-F"]