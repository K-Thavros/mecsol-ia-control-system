#!/bin/bash
set -e

# ===================================================================
# Script: generate_env_secrets.sh
# Descripción: Genera un archivo .env a partir de .env.example,
# rellena las variables de secretos vacías sin imprimirlas en
# pantalla y finalmente asigna permisos seguros al archivo.
# ===================================================================

# Navegar a la raíz del proyecto para que los archivos se creen allí
cd "$(dirname "$0")/.."
ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

# Verificar que .env.example existe
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: El archivo ${EXAMPLE_FILE} no se encuentra."
    exit 1
fi

# Comprobar si .env ya existe
if [ -f "$ENV_FILE" ]; then
    read -p "El archivo ${ENV_FILE} ya existe. ¿Desea sobreescribirlo? (s/N): " choice
    case "$choice" in
      s|S ) echo "Creando un nuevo archivo .env...";;
      * ) echo "Operación cancelada."; exit 0;;
    esac
fi

# Copiar la plantilla para preservar comentarios y estructura
cp "$EXAMPLE_FILE" "$ENV_FILE"

echo "Generando secretos en ${ENV_FILE}..."

# Leer .env.example para identificar qué variables necesitan secretos
while IFS= read -r line || [ -n "$line" ]; do
    # Ignorar comentarios y líneas vacías
    if [[ "$line" =~ ^# ]] || [ -z "$line" ]; then
        continue
    fi

    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)

    # Si el valor está vacío, generar un secreto y reemplazarlo en .env
    if [ -z "$value" ]; then
        secret=$(openssl rand -hex 64)
        # Usar un delimitador que no entre en conflicto con el secreto.
        # sed -i edita el archivo "in-place".
        sed -i "s|^${key}=|${key}=${secret}|" "$ENV_FILE"
        echo "  -> Secreto generado para ${key} (valor oculto)."
    fi
done < "$EXAMPLE_FILE"

# Asignar permisos seguros al archivo .env (solo lectura y escritura para el propietario)
chmod 600 "$ENV_FILE"

echo ""
echo "¡Éxito! El archivo .env ha sido creado y asegurado."
echo "Revise el archivo para confirmar que los valores no secretos son correctos."
