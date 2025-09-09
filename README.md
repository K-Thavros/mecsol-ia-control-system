# Sistema de Ventas Automatizado por IA de MECSOL

Este repositorio contiene la infraestructura y el código para el departamento de ventas automatizado de `mecsol.mx`, controlado por IA. El sistema está diseñado para gestionar el ciclo de vida completo de las ventas de forma autónoma, desde la captación de leads hasta el cierre de contratos.

## Arquitectura del Sistema

El sistema se basa en una arquitectura de microservicios orquestada con Docker Compose. Los componentes principales son:

- **NGINX:** Actúa como proxy inverso, gestionando todo el tráfico entrante y la terminación SSL.
- **Certbot:** Provee certificados SSL de Let's Encrypt con auto-renovación.
- **PostgreSQL:** Es la base de datos central para todos los servicios que requieren persistencia.
- **Odoo:** Sistema ERP/CRM para la gestión de cotizaciones, contratos y facturación.
- **n8n:** Motor de automatización de flujos de trabajo para conectar aplicaciones y orquestar tareas.
- **NocoDB:** Interfaz No-Code para la visualización y gestión directa de la base de datos PostgreSQL.
- **Grafana:** Plataforma de análisis y visualización para los KPIs de negocio.
- **FastAPI:** El "cerebro" del sistema. Un orquestador de IA que contiene la lógica de negocio, gestiona los agentes de IA y se comunica con los demás servicios.

## Guía de Inicio Rápido

Siga estos pasos para levantar el stack completo en un servidor nuevo.

### Prerrequisitos

- Un servidor VPS (recomendado Ubuntu 22.04) con acceso root o sudo.
- Un nombre de dominio (ej. `mecsol-group.com`) con la capacidad de configurar subdominios.
- Los registros DNS para los subdominios definidos en `.env.example` (ej. `api-test.mecsol-group.com`, `odoo-test.mecsol-group.com`) deben apuntar a la IP de su servidor.

### 1. Preparar el Servidor

Conéctese a su servidor y clone el repositorio:

```bash
git clone <URL_DEL_REPOSITORIO> /opt/mecsol-ai
cd /opt/mecsol-ai
```

Ejecute el script de bootstrap para instalar Docker y Docker Compose:

```bash
sudo bash scripts/bootstrap_vps.sh
```

### 2. Configurar el Entorno

Copie el archivo de ejemplo `.env.example` a `.env`:

```bash
cp .env.example .env
```

Edite el archivo `.env` y ajuste las variables de configuración según sus necesidades, especialmente `DOMAIN` y `EMAIL_ACME`. **No rellene los secretos (variables vacías)**.

### 3. Generar Secretos

Ejecute el script de generación de secretos. Este comando rellenará todas las variables vacías en su archivo `.env` con valores criptográficamente seguros y establecerá los permisos del archivo a `600`.

```bash
bash scripts/generate_env_secrets.sh
```

### 4. Levantar los Servicios

Con Docker, la configuración y los secretos listos, levante todo el stack de servicios:

```bash
# Navegue al directorio de compose
cd infra/compose/

# Levante los servicios en segundo plano
docker compose up -d
```

El primer arranque puede tardar varios minutos mientras Docker descarga todas las imágenes de los servicios.

### 5. Verificación

Una vez que los servicios estén en funcionamiento, puede verificar que todo está correcto:

- **Acceda a los subdominios:** Abra en su navegador `https://odoo-test.your-domain.com`, `https://grafana-test.your-domain.com`, etc. Debería ver las interfaces de cada servicio con un certificado SSL válido.
- **Health Check del Orquestador:**
  ```bash
  curl https://api-test.your-domain.com/health
  ```
  La respuesta esperada es `{"status":"ok","service":"MECSOL AI Orchestrator"}`.

## Gestión del Sistema

- **Ver logs:** `docker compose logs -f <nombre_del_servicio>` (ej. `docker compose logs -f fastapi`)
- **Detener servicios:** `docker compose down`
- **Backups:** `bash scripts/backup_pg.sh`
