from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/status')
def status():
    return jsonify({"agent": "operations", "status": "Online"})

@app.route('/data')
def get_data():
    operations_data = {
        "plant_id": "MEC-PLANT-01",
        "efficiency": "92.5%",
        "uptime": "99.8%",
        "active_lines": 5,
        "status": "Todos los sistemas operan dentro de los parámetros normales."
    }
    return jsonify(operations_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
