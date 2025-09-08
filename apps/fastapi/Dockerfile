# Usar una imagen base de Python delgada y eficiente
FROM python:3.9-slim

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar el archivo de requerimientos e instalar dependencias
# Esto se hace en un paso separado para aprovechar el cache de Docker
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip -r requirements.txt

# Copiar el resto del código de la aplicación
COPY . .

# Exponer el puerto en el que correrá la aplicación
EXPOSE 8000

# Comando para ejecutar la aplicación con Uvicorn
# --host 0.0.0.0 hace que sea accesible desde fuera del contenedor
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
