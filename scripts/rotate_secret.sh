#!/bin/bash
set -e

# ===================================================================
# Script: rotate_secret.sh
# Descripción: Rota un secreto específico en el archivo .env y
# reinicia los servicios de Docker Compose que lo utilizan.
# Uso: ./scripts/rotate_secret.sh <NOMBRE_DEL_SECRETO>
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
COMPOSE_FILE="infra/compose/docker-compose.yml"

# --- Validación de Archivos ---
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: El archivo .env no existe. Genérelo primero con generate_env_secrets.sh"
    exit 1
fi
if ! grep -q "^${SECRET_NAME}=" "$ENV_FILE"; then
    echo "Error: El secreto '${SECRET_NAME}' no se encontró en $ENV_FILE"
    exit 1
fi

# --- Rotación del Secreto ---
echo "Generando nuevo secreto para '${SECRET_NAME}'..."
NEW_SECRET=$(openssl rand -hex 64)

# Usamos un delimitador temporal para sed que no entre en conflicto con el secreto
# Creamos una copia de seguridad .bak por si algo falla
sed -i.bak "s#^\(${SECRET_NAME}\)=.*#\1=${NEW_SECRET}#" "$ENV_FILE"
rm "${ENV_FILE}.bak"

echo "El archivo .env ha sido actualizado."

# --- Identificación y Reinicio de Servicios ---
echo "Identificando servicios afectados en ${COMPOSE_FILE}..."

# Usar yq (una herramienta para procesar YAML) sería ideal, pero con grep es posible.
# Buscamos servicios que tengan `env_file: .env` o que usen la variable directamente.
affected_services=$(grep -E "env_file|${SECRET_NAME}" "$COMPOSE_FILE" -B 5 | grep -oE '^[a-z_]+:' | sed 's/://' | sort | uniq)

if [ -z "$affected_services" ]; then
    echo "Advertencia: No se pudo determinar qué servicios reiniciar."
    echo "Se recomienda reiniciar todo el stack: docker-compose -f ${COMPOSE_FILE} up -d --force-recreate"
    exit 0
fi

echo "Los siguientes servicios serán reiniciados para aplicar el nuevo secreto:"
echo "${affected_services}"
echo ""

# El comando `up -d --force-recreate` obliga a los contenedores a ser recreados,
# lo cual es necesario para que tomen las nuevas variables de entorno.
docker-compose -f "$COMPOSE_FILE" up -d --force-recreate ${affected_services}

echo ""
echo "¡Éxito! El secreto ha sido rotado y los servicios afectados se han reiniciado."
