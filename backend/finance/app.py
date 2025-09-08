import json
from flask import Flask, jsonify
from flask_cors import CORS

# ==============================================================================
#  Inicialización de la Aplicación Flask
# ==============================================================================

app = Flask(__name__)

# Configuración de CORS para permitir solicitudes del frontend
CORS(app)


# ==============================================================================
#  Definición de Endpoints de la API
# ==============================================================================

@app.route('/api/financial_summary', methods=['GET'])
def get_financial_summary():
    """
    Endpoint para obtener un resumen de los KPIs financieros clave.
    Lee los datos desde el archivo estático data.json.
    """
    try:
        with open('data.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        return jsonify(data)
    except FileNotFoundError:
        return jsonify({"error": "El archivo de datos (data.json) no fue encontrado."}), 404
    except json.JSONDecodeError:
        return jsonify({"error": "Error al decodificar el archivo JSON. Verifique su formato."}), 500

@app.route('/api/debt_reduction_scenarios', methods=['GET'])
def get_debt_reduction_scenarios():
    """
    Endpoint que devuelve un array de escenarios hipotéticos para la reducción de deuda.
    """
    scenarios = [
        {
            "scenario_name": "Pago Agresivo",
            "description": "Utiliza el 20% del flujo de caja libre excedente para pagos anticipados.",
            "projections": {
                "1_year": {"debt_reduced_mxn": 1200000, "remaining_debt_mxn": 6950000.75},
                "3_years": {"debt_reduced_mxn": 3600000, "remaining_debt_mxn": 4550000.75},
                "5_years": {"debt_reduced_mxn": 6000000, "remaining_debt_mxn": 2150000.75}
            }
        },
        {
            "scenario_name": "Pago Moderado",
            "description": "Utiliza el 10% del flujo de caja libre excedente para pagos anticipados.",
            "projections": {
                "1_year": {"debt_reduced_mxn": 600000, "remaining_debt_mxn": 7550000.75},
                "3_years": {"debt_reduced_mxn": 1800000, "remaining_debt_mxn": 6350000.75},
                "5_years": {"debt_reduced_mxn": 3000000, "remaining_debt_mxn": 5150000.75}
            }
        }
    ]
    return jsonify(scenarios)


# ==============================================================================
#  Bloque de Ejecución Principal (solo para desarrollo local)
# ==============================================================================

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
