# penultimate stable version in april 2025
FROM debian:bullseye/-slim

RUN apt update && apt install -y nginx openssl

ARG DOMAIN_NAME=arepsa@42.fr
ARG USER=arepsa

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/nginx-selfsigned.key \
-out /etc/ssl/nginx-selfsigned.pem \
-subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"

COPY ./conf/nginx.conf /etc/nginx/
COPY ./conf/server.conf /etc/nginx/conf.d/ 

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]