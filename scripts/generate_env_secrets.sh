#!/bin/bash
set -e

# ===================================================================
# Script: generate_env_secrets.sh
# Descripción: Genera un archivo .env a partir de .env.example,
# rellenando las variables vacías con secretos seguros de 64 bytes.
# ===================================================================

# Verificar que .env.example existe en el directorio raíz
if [ ! -f "$(dirname "$0")/../.env.example" ]; then
    echo "Error: El archivo .env.example no se encuentra en la raíz del proyecto."
    exit 1
fi

# Navegar a la raíz del proyecto para que los archivos se creen allí
cd "$(dirname "$0")/.."

# Comprobar si .env ya existe
if [ -f .env ]; then
    read -p "El archivo .env ya existe. ¿Desea sobreescribirlo? (s/N): " choice
    case "$choice" in
      s|S ) echo "Eliminando .env existente y creando uno nuevo..."; rm .env;;
      * ) echo "Operación cancelada. No se ha modificado el archivo .env."; exit 0;;
    esac
fi

echo "Generando archivo .env a partir de .env.example..."

# Leer .env.example y generar .env
while IFS= read -r line || [ -n "$line" ]; do
    # Ignorar comentarios y líneas en blanco
    if [[ "$line" =~ ^# ]] || [ -z "$line" ]; then
        echo "$line" >> .env
        continue
    fi

    # Extraer nombre y valor de la variable
    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)

    # Si el valor después del '=' está vacío, generar un secreto
    if [ -z "$value" ]; then
        # Generar un secreto HEX de 64 bytes (128 caracteres)
        secret=$(openssl rand -hex 64)
        echo "${key}=${secret}" >> .env
        echo "  -> Secreto generado para ${key}"
    else
        # Mantener el valor predefinido
        echo "$line" >> .env
    fi
done < .env.example

# Asignar permisos seguros al archivo .env (solo lectura y escritura para el propietario)
chmod 600 .env

echo ""
echo "¡Éxito! El archivo .env ha sido creado en la raíz del proyecto."
echo "Asegúrese de no incluir este archivo en el control de versiones."
