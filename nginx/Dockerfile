# Dockerfile para el servicio de Proxy (Nginx)

# Utilizar la imagen oficial de Nginx, ligera y estable.
FROM nginx:stable-alpine

# Eliminar el archivo de configuración por defecto para evitar conflictos.
RUN rm /etc/nginx/conf.d/default.conf

# Copiar nuestro archivo de configuración personalizado al directorio de configuraciones de Nginx.
# Nginx cargará automáticamente cualquier archivo .conf de este directorio.
COPY nginx.conf /etc/nginx/conf.d/
