# Usa una imagen base de Nginx ligera
FROM nginx:stable-alpine

# Elimina la configuración por defecto para evitar conflictos
RUN rm /etc/nginx/conf.d/default.conf

# Copia nuestro archivo de configuración personalizado
COPY default.conf /etc/nginx/conf.d/default.conf
