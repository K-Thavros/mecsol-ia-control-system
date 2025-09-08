# Dockerfile para el servicio de Proxy (Nginx)

# 1. Utilizar la imagen oficial y ligera de Nginx.
FROM nginx:stable-alpine

# 2. Eliminar la configuración por defecto que viene con la imagen.
# Esto asegura que solo nuestra configuración personalizada sea utilizada.
RUN rm /etc/nginx/conf.d/default.conf

# 3. Copiar nuestro archivo de configuración personalizado al directorio de Nginx.
# Nginx carga automáticamente todos los archivos .conf de este directorio.
COPY nginx.conf /etc/nginx/conf.d/

# 4. Exponer el puerto 80, el puerto estándar para HTTP.
EXPOSE 80

# 5. Comando para iniciar Nginx en primer plano, lo que es requerido por Docker.
CMD ["nginx", "-g", "daemon off;"]
