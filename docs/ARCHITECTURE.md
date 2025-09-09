# Arquitectura y Flujo de Datos del Sistema de IA de MECSOL

Este documento describe la arquitectura técnica y el flujo de datos del sistema de ventas automatizado.

## Componentes del Stack

Cada servicio se ejecuta en su propio contenedor Docker y está orquestado por Docker Compose.

- **`nginx`**: Actúa como el único punto de entrada a la red (Gateway). Gestiona las peticiones a todos los subdominios, termina las conexiones SSL y redirige el tráfico al servicio interno correspondiente. Su configuración es dinámica y se genera al iniciar a partir de una plantilla y variables de entorno.

- **`certbot`**: Gestiona la obtención y renovación de certificados SSL de Let's Encrypt. Comparte volúmenes con NGINX para almacenar los certificados y resolver el desafío HTTP-01.

- **`postgres`**: Es la base de datos relacional central. Almacena todos los datos de negocio: clientes, leads, cotizaciones, proyectos, etc. Es accedida por la mayoría de los demás servicios. Se ejecuta en una red interna (`internal-net`) por seguridad, sin acceso directo desde el exterior.

- **`odoo`**: Sistema ERP/CRM. Aunque tiene su propia base de datos, en esta arquitectura se configura para usar el `postgres` centralizado. Es utilizado por los agentes de IA (a través de FastAPI) para crear y gestionar registros de ventas como cotizaciones y contratos.

- **`n8n`**: Motor de automatización de flujos de trabajo. Su rol principal es actuar como un "pegamento" entre los sistemas externos (como formularios en `mecsol.mx`) y nuestro orquestador interno.

- **`nocodb`**: Provee una interfaz de usuario tipo hoja de cálculo (similar a Airtable) sobre la base de datos `postgres`. Es una herramienta de administración para que los operadores humanos puedan visualizar y gestionar los datos directamente si es necesario, sin requerir acceso a la base de datos por línea de comandos.

- **`grafana`**: Plataforma de visualización. Se conecta directamente a `postgres` en modo lectura para generar dashboards y visualizar KPIs en tiempo real sobre el rendimiento del embudo de ventas y otros procesos de negocio.

- **`fastapi`**: El **cerebro** del sistema. Es un servicio de Python que aloja al orquestador de IA. Sus responsabilidades son:
    - Exponer una API REST para recibir y gestionar leads.
    - Contener la lógica para la **definición de los agentes de IA** (prompts, personalidades, capacidades).
    - Ejecutar los **algoritmos de optimización** para la asignación de leads.
    - Comunicarse con las APIs de otros servicios (Odoo, SendGrid, Twilio) para que los agentes ejecuten sus tareas.
    - Registrar logs detallados de las decisiones y acciones de los agentes.

## Flujo de un Lead de Venta

El proceso de venta de un servicio de instalación de maquinaria industrial sigue este flujo automatizado:

1.  **Captura del Lead**: Un cliente potencial rellena un formulario en `www.mecsol.mx`.
2.  **Ingesta en n8n**: El formulario envía una petición (webhook) a un endpoint de n8n. El workflow de n8n está diseñado para:
    a. Recibir los datos.
    b. Formatearlos en un objeto JSON estandarizado.
    c. Enviar este JSON al endpoint `/v1/lead/intake` del orquestador FastAPI.
3.  **Procesamiento en FastAPI**:
    a. El orquestador recibe el lead.
    b. Lo guarda en la tabla `leads` de la base de datos `postgres`.
    c. Un **algoritmo de asignación** analiza el lead (ej. por tipo de maquinaria, ubicación) y lo asigna al agente de ventas de IA más adecuado.
4.  **Acción del Agente de IA**:
    a. El agente asignado (un conjunto de prompts y lógica dentro de FastAPI) inicia el proceso de contacto.
    b. Envía un email de presentación al cliente a través de **SendGrid**.
    c. Si se requiere más información, puede mantener una conversación por correo o solicitar una llamada.
5.  **Generación de Cotización**:
    a. Una vez que el agente tiene suficiente información técnica, invoca una función interna que se comunica con la API de **Odoo**.
    b. Crea un nuevo registro de `Cliente` y `Cotización` en Odoo con los detalles técnicos y un precio estimado.
6.  **Cierre y Handoff**:
    a. La cotización se envía al cliente. Si el cliente acepta, el estado del lead se actualiza a `won`.
    b. Se crea un nuevo registro en la tabla `projects` de la base de datos.
    c. El sistema notifica al equipo humano que un nuevo proyecto de instalación está listo para ser gestionado.
7.  **Monitorización**:
    a. Durante todo el proceso, cada cambio de estado se refleja en la base de datos.
    b. **Grafana** visualiza estos datos en tiempo real, mostrando cuántos leads hay en cada etapa del embudo de ventas.
