import os

class Config:
    """Configuración base."""
    SECRET_KEY = os.getenv('SECRET_KEY', 'un-secreto-muy-dificil-de-adivinar')

    # URLs para los otros agentes. Estas se obtendrán del entorno en un despliegue real.
    FINANCE_AGENT_URL = os.getenv('FINANCE_AGENT_URL', 'http://127.0.0.1:5001')
    OPERATIONS_AGENT_URL = os.getenv('OPERATIONS_AGENT_URL', 'http://127.0.0.1:5002')

class DevelopmentConfig(Config):
    """Configuración de desarrollo."""
    DEBUG = True
    FLASK_ENV = 'development'
    # En desarrollo, apuntamos a los mocks que están en el mismo servicio.
    FINANCE_AGENT_URL = 'http://127.0.0.1:5003'
    OPERATIONS_AGENT_URL = 'http://127.0.0.1:5003'


class ProductionConfig(Config):
    """Configuración de producción."""
    DEBUG = False
    FLASK_ENV = 'production'
    # En producción, las URLs deben apuntar a los nombres de servicio de Docker.
    FINANCE_AGENT_URL = os.getenv('FINANCE_AGENT_URL', 'http://finance_agent:5001')
    OPERATIONS_AGENT_URL = os.getenv('OPERATIONS_AGENT_URL', 'http://operations_agent:5002')


# Mapeo de nombres de configuración a clases
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
}

key = Config.SECRET_KEY
