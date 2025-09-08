#!/bin/bash
set -e
set -o pipefail

# ===================================================================
# Script: backup_pg.sh
# Descripción: Realiza un backup de la base de datos PostgreSQL
#              que está corriendo en un contenedor Docker.
# Uso: Ejecutar desde la raíz del proyecto.
#      bash scripts/backup_pg.sh
# ===================================================================

echo "### Iniciando Proceso de Backup de PostgreSQL... ###"

# --- 1. Configuración ---
# Navegar a la raíz del proyecto
cd "$(dirname "$0")/.."
ENV_FILE=".env"
BACKUP_DIR="backups"
CONTAINER_NAME="mecsol_postgres" # Debe coincidir con el docker-compose.yml
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# --- 2. Verificar dependencias ---
# Verificar que .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: El archivo de entorno '${ENV_FILE}' no se encuentra."
    echo "Asegúrese de estar ejecutando el script desde la raíz del proyecto."
    exit 1
fi

# Cargar variables de entorno desde .env
export $(grep -v '^#' $ENV_FILE | xargs)

# Verificar que las variables necesarias están definidas
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_DB" ]; then
    echo "Error: POSTGRES_USER o POSTGRES_DB no están definidos en el archivo .env."
    exit 1
fi

# Verificar que el contenedor está corriendo
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
    echo "Error: El contenedor de PostgreSQL '${CONTAINER_NAME}' no está en ejecución."
    exit 1
fi

# --- 3. Crear el directorio de backup si no existe ---
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="${BACKUP_DIR}/backup-${TIMESTAMP}.sql.gz"

echo "[1/3] Configuración de backup validada."
echo "  -> Contenedor: ${CONTAINER_NAME}"
echo "  -> Base de datos: ${POSTGRES_DB}"
echo "  -> Usuario: ${POSTGRES_USER}"
echo "  -> Archivo de salida: ${BACKUP_FILE}"

# --- 4. Ejecutar pg_dump dentro del contenedor ---
echo "[2/3] Ejecutando pg_dump dentro del contenedor..."

# Usar docker exec para correr pg_dump. La contraseña no es necesaria
# en el comando porque la conexión desde dentro del contenedor
# (como el usuario postgres) a menudo está configurada como 'trust'.
# Si se requiriera, se pasaría a través de la variable PGPASSWORD.
docker exec -t "${CONTAINER_NAME}" pg_dumpall -c -U "${POSTGRES_USER}" | gzip > "${BACKUP_FILE}"

# --- 5. Verificación y Limpieza (Opcional) ---
echo "[3/3] Verificando el archivo de backup..."
if [ -s "$BACKUP_FILE" ]; then
    echo "¡Éxito! Backup creado y guardado en ${BACKUP_FILE}"
    echo "Tamaño: $(du -h ${BACKUP_FILE} | cut -f1)"
else
    echo "Error: ¡El archivo de backup está vacío o no se pudo crear!"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Opcional: Eliminar backups con más de 30 días de antigüedad
# find "$BACKUP_DIR" -name "backup-*.sql.gz" -mtime +30 -exec rm {} \;
# echo "Se eliminaron los backups con más de 30 días de antigüedad."

echo "### Proceso de Backup Completado. ###"
