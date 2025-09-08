#!/bin/bash
set -e

# ===================================================================
# Script: bootstrap_vps.sh
# Descripción: Instala Docker y Docker Compose en un servidor
#              basado en Debian/Ubuntu.
# Uso: Ejecutar como root o con sudo.
#      bash scripts/bootstrap_vps.sh
# ===================================================================

echo "### Iniciando Bootstrap para el VPS de MECSOL... ###"

# --- 1. Actualizar el sistema ---
echo "[1/4] Actualizando lista de paquetes del sistema..."
apt-get update

# --- 2. Instalar dependencias para Docker ---
echo "[2/4] Instalando dependencias necesarias..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# --- 3. Instalar Docker Engine ---
if ! command -v docker &> /dev/null
then
    echo "[3/4] Docker no encontrado. Instalando Docker Engine..."
    # Añadir GPG key oficial de Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Configurar el repositorio de Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instalar Docker Engine y CLI
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
else
    echo "[3/4] Docker ya está instalado. Omitiendo."
fi

# --- 4. Instalar Docker Compose ---
# Docker Compose ahora se distribuye como un plugin de Docker
if ! docker compose version &> /dev/null
then
    echo "[4/4] Docker Compose no encontrado. Instalando..."
    apt-get install -y docker-compose-plugin
else
    echo "[4/4] Docker Compose ya está instalado. Omitiendo."
fi

# --- Verificación Final ---
echo ""
echo "### Bootstrap completado. Verificando instalaciones... ###"
docker --version
docker compose version

echo ""
echo "El sistema está listo para el despliegue de la aplicación MECSOL."
echo "Asegúrese de clonar el repositorio y configurar su archivo .env"
