from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/status')
def status():
    return jsonify({"agent": "commercial", "status": "Online"})

@app.route('/data')
def get_data():
    commercial_data = {
        "lead_id": "COM-LEAD-789",
        "new_leads_today": 42,
        "conversion_rate": "15%",
        "next_action": "Seguimiento con clientes clave de la región LATAM.",
        "market_sentiment": "Positivo"
    }
    return jsonify(commercial_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)
