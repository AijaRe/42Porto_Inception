# penultimate stable version in april 2025
FROM debian:bullseye-slim

RUN apt update && apt install -y nginx openssl

# create a self-signed certificate to serve HTTPS traffic
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/nginx-selfsigned.key \
-out /etc/ssl/nginx-selfsigned.pem \
-subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"

# main configuration directory
COPY ./conf/nginx.conf /etc/nginx/
# subdirectory for site-specific configs
COPY ./conf/server.conf /etc/nginx/conf.d/ 

EXPOSE 443

# run nginx in foreground (as PID 1)
ENTRYPOINT ["nginx", "-g", "daemon off;"]
