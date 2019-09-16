FROM nginx:1.17

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

COPY content /var/content
WORKDIR /var/content

