#!/bin/bash
set -e

# ===================================================================
# Script: backup_pg.sh
# Descripción: Realiza un backup de la base de datos PostgreSQL
# que se ejecuta en Docker. Incluye una política de retención.
# Se recomienda ejecutarlo diariamente a través de un cron job.
# ===================================================================

# --- Configuración ---
# Nombre del contenedor de PostgreSQL (debe coincidir con docker-compose.yml)
CONTAINER_NAME="postgres"
# Directorio raíz del proyecto
PROJECT_ROOT="$(dirname "$0")/.."
# Archivo de entorno para obtener las credenciales
ENV_FILE="${PROJECT_ROOT}/.env"

# Cargar variables de entorno desde el archivo .env
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Error: Archivo .env no encontrado en ${ENV_FILE}"
    exit 1
fi

# Directorio para almacenar los backups
BACKUP_DIR="${PROJECT_ROOT}/db/backups"
# Días de retención para los backups antiguos
RETENTION_DAYS=7
# Formato de fecha para el nombre del archivo
DATE_FORMAT=$(date +"%Y-%m-%d_%H-%M-%S")
# Nombre final del archivo de backup
BACKUP_FILE="${BACKUP_DIR}/${POSTGRES_DB}_${DATE_FORMAT}.sql.gz"

# --- Lógica del Script ---
echo "Iniciando backup de la base de datos '${POSTGRES_DB}'..."

# 1. Crear el directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# 2. Verificar que el contenedor de Docker esté corriendo
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: El contenedor de PostgreSQL '${CONTAINER_NAME}' no está en ejecución."
    exit 1
fi

# 3. Ejecutar pg_dump dentro del contenedor
#    -U: Usuario, -d: Base de datos
#    La salida se comprime con gzip y se guarda en el archivo de backup.
docker exec "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" | gzip > "$BACKUP_FILE"

# 4. Verificar que el comando anterior fue exitoso
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Error: Falla al ejecutar pg_dump. Se eliminará el archivo de backup corrupto."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "Backup creado exitosamente en: ${BACKUP_FILE}"

# 5. Aplicar política de retención
echo "Aplicando política de retención de ${RETENTION_DAYS} días en ${BACKUP_DIR}..."
# find busca archivos (-type f) con nombre *.sql.gz, modificados hace más de
# RETENTION_DAYS días (-mtime +$RETENTION_DAYS) y los elimina (-delete).
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime "+$RETENTION_DAYS" -print -delete

echo "Limpieza de backups antiguos completada."
echo "Proceso de backup finalizado."
