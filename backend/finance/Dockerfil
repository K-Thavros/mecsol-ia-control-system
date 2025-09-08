# 1. Definir la imagen base
# Se utiliza python:3.9-slim por ser una versión ligera y específica.
FROM python:3.9-slim

# 2. Establecer el directorio de trabajo
WORKDIR /app

# 3. Copiar el archivo de dependencias
# Se copia primero 'requirements.txt' para aprovechar el sistema de caché de Docker.
COPY requirements.txt .

# 4. Instalar las dependencias
# Se añade 'gunicorn' explícitamente para producción.
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 5. Copiar el resto del código de la aplicación
COPY . .

# 6. Exponer el puerto de la aplicación
EXPOSE 5001

# 7. Definir el comando de ejecución para producción con Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "4", "app:app"]
