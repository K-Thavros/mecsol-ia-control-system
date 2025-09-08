from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/status')
def status():
    return jsonify({"agent": "finance", "status": "Online"})

@app.route('/data')
def get_data():
    financial_data = {
        "report_id": "FIN-2025-Q3",
        "revenue": 5250000,
        "profit": 1230000,
        "currency": "USD",
        "summary": "Resultados trimestrales positivos con crecimiento en todas las áreas."
    }
    return jsonify(financial_data)

if __name__ == '__main__':
    # Este bloque no se ejecutará cuando se use Gunicorn, pero es útil para pruebas locales.
    app.run(host='0.0.0.0', port=5001)
