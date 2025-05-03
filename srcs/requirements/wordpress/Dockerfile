# penultimate stable version in april 2025
FROM debian:bullseye-slim

# Set Wordpress version
ARG WP_VERSION=6.7.1
# ARG WP_CLI_VERSION=2.11.0

# Install necessary packages
# wget - for downloading files (Wordpress and wp-cli)
# php-fpm - for running PHP applications
# php-mysql - for MySQL database connection
# mariadb-client - for wp-cli database management
RUN apt update && apt install -y --no-install-recommends \
	ca-certificates \
	gosu \
	wget \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-gd \
	mariadb-client \
	tar \
	rsync \
	# cleanup
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/*

# Prepare target directory
RUN mkdir -p /var/www/html \
	&& mkdir -p /usr/src/wordpress

# Download and extract Wordpress
RUN wget https://wordpress.org/wordpress-${WP_VERSION}.tar.gz -O wordpress.tar.gz \
	&& tar -xzf wordpress.tar.gz --strip-components=1 -C /usr/src/wordpress \
	&& rm wordpress.tar.gz
	
# Set permissions for Wordpress files
#RUN chown -R www-data:www-data /var/www/html/ \
#	&& chmod -R 755 /var/www/html/ \
#	&& mkdir -p /var/www/html/wp-content/ \
#	&& find /var/www/html/wp-content -type d -exec chmod 755 {} \; \
 #   && find /var/www/html/wp-content -type f -exec chmod 644 {} \;

# Download and install wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp
# Create wp-cli cache/config dir owned by www-data
RUN mkdir -p /home/www-data/.wp-cli/cache \
	&& chown -R www-data:www-data /home/www-data/.wp-cli
#	&& mkdir -p /var/www/html/wp-content/uploads/ \
#	&& mkdir -p /var/www/html/.wp-cli \
#	&& chown -R www-data:www-data /var/www/html/.wp-cli

# Configure PHP-FPM
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Set the working directory
WORKDIR /var/www/html

# Copy the entrypoint script and make it executable
COPY ./tools/wp_exec.sh /usr/local/bin/wp_exec.sh
RUN chmod +x /usr/local/bin/wp_exec.sh

EXPOSE 9000

# Set the entrypoint to the script
# Run php-fpm in foreground mode (to prevent daemonizing) as the final command via exec in the script
ENTRYPOINT ["/usr/local/bin/wp_exec.sh"]
# Pass php-fpm command as CMD, so it can be overridden if needed
CMD ["php-fpm7.4", "-F"]
