# Usa una imagen base de Nginx ligera
FROM nginx:stable-alpine

# Elimina la configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia el archivo del dashboard al directorio web de Nginx
COPY index.html /usr/share/nginx/html/index.html
