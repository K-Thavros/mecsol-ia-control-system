# Guía de Configuración y Despliegue

Este documento proporciona una guía detallada para la configuración, despliegue y mantenimiento del sistema MECSOL.

## 1. Gestión de Secretos

La seguridad de las credenciales y claves de API es crítica. Toda la gestión de secretos se realiza a través de un archivo `.env` que **nunca** debe ser subido al repositorio de código. El archivo `.gitignore` está configurado para prevenir esto.

### 1.1. Archivo de Ejemplo (`.env.example`)

El archivo `.env.example` es la plantilla para los secretos. Contiene todas las variables de entorno que la aplicación necesita, con valores predeterminados para la configuración y valores vacíos para los secretos.

### 1.2. Generación del Archivo `.env`

Para crear tu archivo `.env` por primera vez:

1.  **Copia la plantilla**:
    ```bash
    cp .env.example .env
    ```
2.  **Edita los valores no secretos**:
    Abre el archivo `.env` y ajusta los valores de `ENVIRONMENT`, `TZ`, `NOTIFY_EMAIL`, etc., para que coincidan con tu configuración.
3.  **Genera los secretos**:
    Usa el script `generate_env_secrets.sh` para rellenar automáticamente todas las variables de secretos vacías.
    ```bash
    chmod +x scripts/generate_env_secrets.sh
    bash scripts/generate_env_secrets.sh
    ```
    El script generará valores HEX de 64 bytes para cada secreto y establecerá los permisos del archivo `.env` a `600` (solo lectura/escritura para el propietario) para mayor seguridad. No imprimirá los secretos en la consola.

### 1.3. Rotación de Secretos

Si un secreto se ve comprometido o como parte de una política de seguridad regular, puedes rotarlo usando el script `rotate_secret.sh`.

**Uso:**
```bash
bash scripts/rotate_secret.sh <NOMBRE_DEL_SECRETO>
```

**Ejemplo:**
```bash
bash scripts/rotate_secret.sh POSTGRES_PASSWORD
```

Este comando:
1.  Creará un backup de tu archivo `.env` actual con un timestamp (ej. `.env.bak-20230907-214500`).
2.  Generará un nuevo secreto para la variable `POSTGRES_PASSWORD`.
3.  Simulará el reinicio de los servicios de Docker Compose que dependen de ese secreto.

## 2. Despliegue en VPS (Guía Simplificada)

1.  **Apunta tu DNS**: Asegúrate de que los subdominios necesarios apunten a la IP de tu VPS.
2.  **Clona el repositorio**:
    ```bash
    git clone <URL_DEL_REPOSITORIO> /opt/mecsol-app
    cd /opt/mecsol-app
    ```
3.  **Configura y genera tu `.env`**: Sigue los pasos detallados en la sección 1.2 de este documento.
4.  **Ejecuta el script de bootstrap**: (Nota: Este script no está incluido en esta tarea, pero aquí irían los pasos para instalar Docker y levantar los servicios).
    ```bash
    # sudo bash scripts/bootstrap_vps.sh
    ```

## 3. Smoke Tests (Pruebas Rápidas)

Después de un despliegue, verifica que los servicios básicos funcionan correctamente.

-   **[ ] Verificar el endpoint de Health Check**:
    Usa `curl` para comprobar que un servicio hipotético `api` está respondiendo.
    ```bash
    curl https://api-test.tu-dominio.com/health
    ```
    Respuesta esperada: `{"status":"ok"}`.

-   **[ ] Verificar certificados SSL**:
    Usa `openssl` para comprobar que el certificado es válido y emitido por Let's Encrypt.
    ```bash
    openssl s_client -connect api-test.tu-dominio.com:443 -servername api-test.tu-dominio.com < /dev/null 2>/dev/null | grep "issuer"
    ```
    La salida esperada debería contener `O = Let's Encrypt`.
