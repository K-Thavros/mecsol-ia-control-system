from flask import Flask
from config import config_by_name

def create_app(config_name):
    """
    Factory de la aplicación Flask.
    """
    app = Flask(__name__)
    
    # Cargar la configuración desde el objeto de configuración
    app.config.from_object(config_by_name[config_name])
    
    # Registrar Blueprints (rutas)
    from .api.commercial_agent_api import commercial_bp
    from .api.mock_external_agents_api import mock_agents_bp
    
    app.register_blueprint(commercial_bp, url_prefix='/api/commercial')
    
    # Solo registrar los mocks si no estamos en producción.
    if app.config['DEBUG']:
        app.register_blueprint(mock_agents_bp, url_prefix='/api')

    @app.route('/health')
    def health_check():
        return "Agente Comercial: OK", 200

    return app
