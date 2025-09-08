#!/bin/bash
set -e

# ===================================================================
# Script: rotate_secret.sh
# Descripción: Rota un secreto específico en el archivo .env,
# crea un backup con timestamp y reinicia los servicios afectados.
# ===================================================================

# --- Validación de Argumentos ---
if [ "$#" -ne 1 ]; then
    echo "Error: Se requiere el nombre del secreto como argumento."
    echo "Uso: $0 NOMBRE_DEL_SECRETO"
    echo "Ejemplo: $0 POSTGRES_PASSWORD"
    exit 1
fi

SECRET_NAME=$1
# Navegar a la raíz del proyecto
cd "$(dirname "$0")/.."
ENV_FILE=".env"

# --- Validación de Archivos ---
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: El archivo .env no existe. Genérelo primero con 'scripts/generate_env_secrets.sh'."
    exit 1
fi
if ! grep -q "^${SECRET_NAME}=" "$ENV_FILE"; then
    echo "Error: El secreto '${SECRET_NAME}' no se encontró en ${ENV_FILE}."
    exit 1
fi

# --- Backup y Rotación ---
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="${ENV_FILE}.bak-${TIMESTAMP}"
echo "Creando backup de ${ENV_FILE} en: ${BACKUP_FILE}"
cp "$ENV_FILE" "$BACKUP_FILE"

echo "Generando nuevo secreto para '${SECRET_NAME}'..."
NEW_SECRET=$(openssl rand -hex 64)

# Usar sed para reemplazar la línea que contiene el secreto.
sed -i "s#^\(${SECRET_NAME}\)=.*#\1=${NEW_SECRET}#" "$ENV_FILE"

echo "El archivo .env ha sido actualizado con el nuevo secreto."

# --- Reinicio de Servicios ---
echo ""
echo "Identificando y reiniciando servicios afectados..."
# En un entorno real con docker-compose.yml, aquí se podría usar grep
# para encontrar los servicios que usan la variable y reiniciarlos.
# Ejemplo: affected_services=$(grep -l "\${${SECRET_NAME}}" -r . | ...)
# docker-compose restart ${affected_services}
echo "Simulación: En un entorno real, los servicios afectados por el cambio en \${${SECRET_NAME}} serían reiniciados aquí."
echo "(Ejemplo: docker-compose restart postgres odoo fastapi)"


echo ""
echo "¡Éxito! El secreto ha sido rotado."
echo "Backup guardado en ${BACKUP_FILE}."
