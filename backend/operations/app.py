import json
from flask import Flask, jsonify
from flask_cors import CORS
from logic.operations_logic import (
    schedule_projects, 
    allocate_resources, 
    get_operations_status
)

app = Flask(__name__)
CORS(app)  # Habilitar CORS

# Cargar los datos una vez al iniciar la aplicación
def load_data():
    try:
        with open('data/data.json', 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        # En caso de no encontrar el archivo, se detiene la aplicación
        # ya que es una dependencia crítica para este servicio.
        raise RuntimeError("El archivo data/data.json es esencial y no fue encontrado.")

db = load_data()

# --- Endpoints de la API ---

@app.route('/api/operations/status', methods=['GET'])
def api_get_operations_status():
    """Endpoint que provee un resumen del estado operativo actual."""
    status = get_operations_status(db)
    return jsonify(status)

@app.route('/api/projects/schedule', methods=['GET'])
def api_schedule_projects():
    """Endpoint que simula la planificación de proyectos."""
    weights = {'w_m': 0.5, 'w_u': 0.3, 'w_r': 0.2}
    scheduled_projects = schedule_projects(db, weights)
    return jsonify(scheduled_projects)

@app.route('/api/resources/allocation', methods=['GET'])
def api_allocate_resources():
    """Endpoint que retorna un plan de asignación óptimo."""
    allocation_plan = allocate_resources(db)
    return jsonify(allocation_plan)

if __name__ == '__main__':
    # Para desarrollo. En producción se usa Gunicorn.
    app.run(debug=True, port=5002)
