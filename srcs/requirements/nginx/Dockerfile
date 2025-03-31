# penultimate stable version in april 2025
FROM debian:bullseye

RUN apt update && apt install -y nginx openssl

COPY ./conf/nginx.conf /etc/nginx/
COPY ./conf/server.conf /etc/nginx/conf.d/ 

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]