# Dockerfile para el servicio de Frontend

# 1. Utilizar una imagen de Nginx muy ligera para servir contenido estático.
FROM nginx:stable-alpine

# 2. Copiar todos los archivos del frontend (HTML, CSS, JS) al directorio raíz 
# del servidor web por defecto de Nginx.
COPY . /usr/share/nginx/html

# 3. Exponer el puerto 80, que es el puerto HTTP estándar que Nginx escucha.
EXPOSE 80

# 4. El comando por defecto de la imagen base de Nginx es suficiente, pero se añade
# explícitamente para mayor claridad. Esto inicia el servidor en primer plano.
CMD ["nginx", "-g", "daemon off;"]
