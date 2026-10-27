FROM nginx:alpine

# Instalar las correcciones de seguridad publicadas después de la imagen base.
RUN apk upgrade --no-cache

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
EXPOSE 80
