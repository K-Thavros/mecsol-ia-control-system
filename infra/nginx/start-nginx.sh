#!/bin/sh
set -e

# ===================================================================
# Script: start-nginx.sh
# Descripción: Prepara la configuración de NGINX sustituyendo
#              variables de entorno y luego permite que NGINX inicie.
# ===================================================================

# Define la ruta de la plantilla y el archivo de configuración de salida
TEMPLATE_FILE="/etc/nginx/templates/app.conf.template"
CONFIG_FILE="/etc/nginx/conf.d/default.conf"

# Exportar las variables de entorno que envsubst debe sustituir
# El comando 'envsubst' reemplazará ${VAR} en la plantilla con el valor
# de la variable de entorno VAR.
# El 'DOLLAR' se usa para proteger las variables internas de NGINX (ej. $host)
export DOLLAR='$'
export API_SUBDOMAIN
export DOMAIN
export ODOO_SUBDOMAIN
export N8N_SUBDOMAIN
export NOCO_SUBDOMAIN
export GRAFANA_SUBDOMAIN

echo "Generando el archivo de configuración de NGINX desde la plantilla..."
envsubst < "$TEMPLATE_FILE" > "$CONFIG_FILE"

echo "Archivo de configuración de NGINX generado exitosamente."

# El entrypoint original de la imagen de NGINX se encargará de ejecutar
# el servidor NGINX después de que este script termine, ya que se
# encuentra en /docker-entrypoint.d/
exit 0
