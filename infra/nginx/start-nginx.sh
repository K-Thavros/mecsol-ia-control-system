#!/bin/sh
set -e

# ===================================================================
# Script: start-nginx.sh
# Descripción: Prepara la configuración de NGINX sustituyendo
#              variables de entorno y luego inicia el servidor.
# ===================================================================

# Define la ruta de la plantilla y el archivo de configuración de salida
TEMPLATE_FILE="/etc/nginx/templates/app.conf.template"
CONFIG_FILE="/etc/nginx/conf.d/default.conf"

echo "Generando el archivo de configuración de NGINX desde la plantilla..."

# Exportar las variables de entorno para que envsubst las pueda usar
export DOLLAR='$'
export API_SUBDOMAIN
export DOMAIN
export ODOO_SUBDOMAIN
export N8N_SUBDOMAIN
export NOCO_SUBDOMAIN
export GRAFANA_SUBDOMAIN

# Usar envsubst para sustituir las variables.
# El '$$' en la plantilla se convertirá en un solo '$' para las variables de NGINX.
# Esto es para proteger las variables internas de NGINX como $host y $request_uri.
envsubst < "$TEMPLATE_FILE" > "$CONFIG_FILE"

echo "Archivo de configuración generado en ${CONFIG_FILE}."
echo "Contenido del archivo de configuración:"
cat "${CONFIG_FILE}"
echo "--- Fin del archivo de configuración ---"

# El entrypoint original de la imagen de NGINX se encargará de ejecutar
# el servidor NGINX después de que este script termine.
# Por lo tanto, no es necesario llamar a 'nginx -g "daemon off;"' aquí si
# se coloca el script en /docker-entrypoint.d/
echo "Saliendo del script de inicialización. NGINX se iniciará ahora."
