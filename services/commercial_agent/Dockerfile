# Dockerfile para el microservicio: Agente Comercial
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn
COPY . .
EXPOSE 5003
CMD ["gunicorn", "--bind", "0.0.0.0:5003", "--workers", "4", "wsgi:app"]
