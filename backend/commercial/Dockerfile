# Dockerfile para el microservicio: Agente Comercial

# 1. Imagen Base: Utiliza una imagen oficial de Python, versión "slim".
FROM python:3.9-slim

# 2. Establece el directorio de trabajo dentro del contenedor a /app.
WORKDIR /app

# 3. Copia primero el archivo de dependencias para aprovechar el cache de Docker.
COPY requirements.txt .

# 4. Instala las dependencias, incluyendo Gunicorn para producción.
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 5. Copia el resto del código fuente de la aplicación al directorio de trabajo.
COPY . .

# 6. Expone el puerto 5003. El contenedor escuchará en este puerto internamente.
EXPOSE 5003

# 7. Comando para iniciar la aplicación en producción usando Gunicorn.
#    - run:app: Le indica a Gunicorn que busque el objeto 'app' en el archivo 'run.py'.
CMD ["gunicorn", "--bind", "0.0.0.0:5003", "--workers", "4", "run:app"]
