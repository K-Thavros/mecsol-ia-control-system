import os
from dotenv import load_dotenv

# Cargar variables de entorno desde el archivo .env
# Es crucial que esto ocurra antes de crear la app.
load_dotenv()

from app import create_app

# Obtener la configuración del entorno, por defecto 'development'
env_name = os.getenv('FLASK_ENV', 'development')
app = create_app(env_name)

if __name__ == '__main__':
    # El servidor de desarrollo de Flask no es para producción.
    # En producción, Gunicorn ejecutará la aplicación.
    app.run()
