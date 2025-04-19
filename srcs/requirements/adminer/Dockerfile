# penultimate stable version in april 2025
FROM debian:bullseye-slim

RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates \
    wget \
    php-fpm \
    php-mysqli \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html /run/php

RUN wget "https://github.com/vrana/adminer/releases/download/v5.2.1/adminer-5.2.1.php" -O /var/www/html/adminer.php

# Adjust PHP-FPM configuration to listen on a TCP socket
# facilitate Nginx to connect to it across containers
RUN sed -i 's/listen = \/run\/php\/.*\.sock/listen = 9000/' /etc/php/*/fpm/pool.d/www.conf

# Expose the PHP-FPM port
EXPOSE 9000

# Command to run PHP-FPM
ENTRYPOINT ["/usr/sbin/php-fpm7.4", "-F"]
