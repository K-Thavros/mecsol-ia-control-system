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

# Cargar variables de entorno desde .env para este script
export $(grep -v '^#' $ENV_FILE | xargs)

# Verificar que las variables necesarias están definidas
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Error: POSTGRES_USER, POSTGRES_DB, o POSTGRES_PASSWORD no están definidos en .env."
    exit 1
fi

# Verificar que el contenedor está corriendo
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
    echo "Error: El contenedor de PostgreSQL '${CONTAINER_NAME}' no está en ejecución."
    echo "Por favor, inicie el stack con 'docker compose up -d'."
    exit 1
fi

# --- 3. Crear el directorio de backup si no existe ---
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="${BACKUP_DIR}/backup-${TIMESTAMP}.sql.gz"

echo "[1/3] Configuración de backup validada."
echo "  -> Contenedor: ${CONTAINER_NAME}"
echo "  -> Base de datos: ${POSTGRES_DB}"
echo "  -> Archivo de salida: ${BACKUP_FILE}"

# --- 4. Ejecutar pg_dump dentro del contenedor ---
echo "[2/3] Ejecutando pg_dump dentro del contenedor..."

# PGPASSWORD se pasa como variable de entorno al comando docker exec
docker exec -e PGPASSWORD=$POSTGRES_PASSWORD \
    "${CONTAINER_NAME}" pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -F c -b | gzip > "${BACKUP_FILE}"

# --- 5. Verificación y Limpieza ---
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
find "$BACKUP_DIR" -name "backup-*.sql.gz" -mtime +30 -exec rm {} \;
echo "Se eliminaron los backups con más de 30 días de antigüedad (si los hubiera)."

echo "### Proceso de Backup Completado. ###"
