# Departamento Automatizado de Ventas MECSOL

Este repositorio contiene la infraestructura y el código para el sistema de ventas 100% autónomo de MECSOL. El sistema está diseñado para gestionar marketing, ventas, proyectos y servicio al cliente con mínima intervención humana, operando sobre una infraestructura de microservicios en un VPS.

## Arquitectura del Sistema

El sistema se basa en una arquitectura de microservicios orquestada por Docker Compose. Los componentes principales son:

- **NGINX**: Actúa como reverse proxy, gestionando todo el tráfico entrante, aplicando terminación SSL y headers de seguridad.
- **Certbot**: Provee certificados SSL de Let's Encrypt y los renueva automáticamente para todos los subdominios.
- **PostgreSQL**: Es la base de datos central para los servicios que la requieran (NocoDB, n8n, Odoo, etc.).
- **Odoo**: Sistema ERP utilizado para CRM, cotizaciones, contratos y facturación.
- **NocoDB**: Plataforma no-code que funciona como una base de datos inteligente (similar a Airtable) para la gestión de tablas de datos como proyectos y tickets.
- **n8n**: Herramienta de automatización de workflows que conecta todos los servicios entre sí y con APIs externas.
- **Grafana**: Plataforma de analítica y visualización de datos para monitorizar KPIs de negocio en tiempo real.
- **FastAPI**: Orquestador de IA que funciona como el cerebro del sistema, coordinando agentes de IA y ejecutando lógica de negocio compleja.

## Estructura del Repositorio

```
/
├── .env.example            # Plantilla para variables de entorno y secretos
├── apps/
│   └── fastapi/            # Código fuente del orquestador IA (FastAPI)
├── dashboards/
│   └── grafana/            # Dashboards de Grafana en formato JSON para provisioning
├── db/
│   ├── backups/            # Directorio para backups de la base de datos (generados por script)
│   └── sql/                # Esquema DDL inicial de la base de datos
├── docs/                   # Documentación adicional (diagramas, guías de operación, ADRs)
├── infra/
│   ├── certbot/            # Volúmenes para los datos de Certbot (certificados)
│   ├── compose/
│   │   └── docker-compose.yml # Archivo principal que define todo el stack de servicios
│   └── nginx/              # Configuraciones de NGINX (templates, server blocks)
├── pipelines/
│   └── n8n/                # Workflows de n8n exportados en formato JSON
└── scripts/                # Scripts de utilidad (bootstrap, backups, rotación de secretos)
```

## Guía de Despliegue Rápido

Siga estos pasos para desplegar el sistema en un VPS nuevo (probado en Debian/Ubuntu).

### Prerrequisitos

1. Un VPS limpio con acceso `root`.
2. Un dominio (ej. `mecsol-group.com`) con los registros DNS de tipo `A` apuntando a la IP de su VPS para cada subdominio.
   - Para entorno `test`: `api-test.mecsol-group.com`, `noco-test.mecsol-group.com`, etc.
   - Para entorno `prod`: `api-prod.mecsol-group.com`, `noco-prod.mecsol-group.com`, etc.

### Pasos de Instalación

1. **Clonar el repositorio en el VPS:**
   ```bash
   git clone <URL_DEL_REPOSITORIO> /opt/mecsol-stack
   cd /opt/mecsol-stack
   ```

2. **Crear y configurar el archivo `.env`:**
   Copie la plantilla y edítela para definir su entorno.
   ```bash
   cp .env.example .env
   ```
   A continuación, edite el archivo `.env` y configure las variables `ENVIRONMENT` (test/prod), `DOMAIN` y `CERTBOT_EMAIL`. **No es necesario rellenar los secretos**, el siguiente script lo hará automáticamente.

3. **Generar secretos de forma segura:**
   Ejecute el script que puebla el archivo `.env` con secretos criptográficamente seguros.
   ```bash
   chmod +x scripts/generate_env_secrets.sh
   bash scripts/generate_env_secrets.sh
   ```

4. **Ejecutar el script de Bootstrap:**
   Este script instalará Docker, configurará el firewall y desplegará todo el stack de servicios.
   ```bash
   chmod +x scripts/bootstrap_vps.sh
   sudo bash scripts/bootstrap_vps.sh
   ```
   El script se encargará de todo el proceso, incluyendo la solicitud de certificados SSL reales. Al finalizar, todos los servicios estarán en línea y accesibles a través de sus respectivos subdominios.

## Scripts de Operación y Mantenimiento

Todos los scripts se encuentran en el directorio `/scripts`.

- `generate_env_secrets.sh`: Crea el archivo `.env` a partir de la plantilla.
- `rotate_secret.sh <NOMBRE_DEL_SECRETO>`: Rota un secreto específico y reinicia los servicios afectados.
- `backup_pg.sh`: Realiza un backup de la base de datos principal. Diseñado para ser ejecutado por un `cron job`.
- `bootstrap_vps.sh`: Script de instalación inicial para un servidor nuevo.

## Documentación Adicional

Para más detalles sobre la arquitectura, decisiones de diseño (ADRs) y guías de operación, consulte los documentos en el directorio `/docs`.
