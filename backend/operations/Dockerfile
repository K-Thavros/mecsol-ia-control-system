# Dockerfile para el microservicio del Agente de Operaciones

# 1. Usar la imagen base oficial de Python, versión 'slim'.
FROM python:3.9-slim

# 2. Establecer el directorio de trabajo dentro del contenedor.
WORKDIR /app

# 3. Copiar el archivo de dependencias primero para aprovechar el cache de Docker.
COPY requirements.txt .

# 4. Instalar las dependencias del proyecto usando pip.
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 5. Copiar el resto del código de la aplicación al directorio de trabajo.
COPY . .

# 6. Exponer el puerto que Gunicorn usará dentro del contenedor.
EXPOSE 5002

# 7. Comando para iniciar la aplicación en producción con Gunicorn.
CMD ["gunicorn", "--bind", "0.0.0.0:5002", "--workers", "4", "app:app"]
