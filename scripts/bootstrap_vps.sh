#!/bin/bash
set -e

# ===================================================================
# Script: bootstrap_vps.sh
# Descripción: Prepara un VPS nuevo (basado en Debian/Ubuntu) e
# instala y despliega el stack completo de la aplicación.
# ¡ADVERTENCIA! Este script debe ejecutarse con permisos de root.
# ===================================================================

# --- Verificación de Root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root. Use 'sudo bash $0'"
    exit 1
fi

echo "--- Iniciando Bootstrap del Servidor MECSOL ---"

# --- 1. Instalación de Dependencias (Docker, Docker Compose, Git) ---
echo ">>> Paso 1: Instalando Docker, Docker Compose y otras herramientas..."
apt-get update
apt-get install -y curl git ufw

# Instalar Docker (usando el script oficial para simplicidad)
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker ya está instalado."
fi

# Instalar Docker Compose v2 (viene como plugin de Docker)
if ! docker compose version &> /dev/null; then
    echo "Docker Compose no se encontró, por favor instálelo manualmente."
    exit 1
fi

# --- 2. Configuración del Firewall (UFW) ---
echo ">>> Paso 2: Configurando el firewall (UFW)..."
ufw allow OpenSSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw --force enable
echo "Firewall configurado y activado."

# --- 3. Preparación del Directorio y Archivos ---
# Asumimos que el script se ejecuta desde el directorio /scripts
cd "$(dirname "$0")/.."
APP_DIR=$(pwd)
echo "Directorio de la aplicación: ${APP_DIR}"

# Generar archivo .env si no existe
if [ ! -f ".env" ]; then
    echo ">>> Paso 3: Generando archivo .env con secretos..."
    bash scripts/generate_env_secrets.sh
else
    echo ">>> Paso 3: El archivo .env ya existe, omitiendo generación."
fi
# Cargar variables para usarlas en el script
export $(grep -v '^#' .env | xargs)

# --- 4. Creación de Certificados Dummy ---
echo ">>> Paso 4: Creando certificados SSL dummy para el arranque de NGINX..."
# NGINX fallará si no encuentra los archivos de certificado al iniciar.
# Se crean certificados autofirmados temporales.
# Lista de dominios desde .env
DOMAINS="api-${ENVIRONMENT}.${DOMAIN} noco-${ENVIRONMENT}.${DOMAIN} grafana-${ENVIRONMENT}.${DOMAIN} n8n-${ENVIRONMENT}.${DOMAIN} odoo-${ENVIRONMENT}.${DOMAIN}"

for domain in $DOMAINS; do
    dummy_path="/etc/letsencrypt/live/${domain}"
    # Usamos el volumen de certbot definido en docker-compose
    mkdir -p "certbot_etc/live/${domain}"
    if [ ! -f "certbot_etc/live/${domain}/fullchain.pem" ]; then
        echo "Creando certificado dummy para ${domain}"
        openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
            -keyout "certbot_etc/live/${domain}/privkey.pem" \
            -out "certbot_etc/live/${domain}/fullchain.pem" \
            -subj "/CN=localhost"
    fi
done

# --- 5. Iniciar todos los servicios ---
echo ">>> Paso 5: Construyendo e iniciando todos los servicios con Docker Compose..."
docker compose -f infra/compose/docker-compose.yml up -d --build

# --- 6. Obtener Certificados Reales de Let's Encrypt ---
echo ">>> Paso 6: Solicitando certificados reales de Let's Encrypt..."
# Eliminar los certificados dummy antes de solicitar los reales
echo "Eliminando certificados dummy..."
for domain in $DOMAINS; do
    rm -rf "certbot_etc/live/${domain}"
    rm -rf "certbot_etc/archive/${domain}"
    rm -rf "certbot_etc/renewal/${domain}.conf"
done

# Construir los argumentos -d para certbot
certbot_domains_args=""
for domain in $DOMAINS; do
    certbot_domains_args+=" -d ${domain}"
done

echo "Ejecutando Certbot..."
docker compose -f infra/compose/docker-compose.yml run --rm certbot certonly \
    --webroot \
    --webroot-path /var/www/certbot \
    --email "${CERTBOT_EMAIL}" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    ${certbot_domains_args}

# --- 7. Reiniciar NGINX para aplicar certificados ---
echo ">>> Paso 7: Reiniciando NGINX para cargar los nuevos certificados..."
docker compose -f infra/compose/docker-compose.yml restart nginx

echo ""
echo "==================================================================="
echo "¡Despliegue completado!"
echo "El sistema MECSOL está ahora en línea."
echo "==================================================================="
