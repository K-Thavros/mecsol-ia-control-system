# Usar la imagen oficial de NGINX como base
FROM nginx:1.25-alpine

# Instalar 'gettext' que provee la utilidad 'envsubst'.
# Se actualiza la lista de paquetes, se instala y se limpia la caché
# para mantener la imagen lo más pequeña posible.
RUN apk update && apk add --no-cache gettext

# Copiar el script de inicio al directorio de entrypoint de NGINX.
# Los scripts en este directorio se ejecutan antes de que NGINX inicie.
COPY start-nginx.sh /docker-entrypoint.d/99-start-nginx.sh

# Hacer el script de inicio ejecutable
RUN chmod +x /docker-entrypoint.d/99-start-nginx.sh
