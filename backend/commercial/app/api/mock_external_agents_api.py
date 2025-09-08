import time
import requests
from flask import Blueprint, request, jsonify, current_app

# Este Blueprint simula las APIs de los otros agentes para pruebas aisladas.
mock_agents_bp = Blueprint('mock_agents_api', __name__)

@mock_agents_bp.route('/operations/capacity-check', methods=['POST'])
def mock_capacity_check():
    data = request.get_json()
    request_id = data.get('request_id')

    mock_response = {
      "check_id": f"CAP-CHECK-{int(time.time())}", "can_be_fulfilled": True,
      "confidence_score": 0.90, "potential_bottlenecks": ["Disponibilidad de soldadores TIG será ajustada."],
      "estimated_start_date": "2025-11-05"
    }

    callback_url = f"http://127.0.0.1:5003/api/commercial/capacity-check-response/{request_id}"
    try:
        requests.post(callback_url, json=mock_response, timeout=5)
    except requests.exceptions.RequestException as e:
        print(f"Mock-Operations: Could not call back Commercial Agent. Error: {e}")

    return jsonify({"message": "Capacity check received by mock Operations. Processing..."}), 202


@mock_agents_bp.route('/finance/quote-costing-request', methods=['POST'])
def mock_quote_costing():
    data = request.get_json()
    quote_id = data.get('quote_id')
    direct_costs = data.get('estimated_direct_costs', 0)

    fcf_rate = 0.30
    base_cost = direct_costs * (1 + fcf_rate)

    mock_response = {
      "quote_id": quote_id, "base_cost_for_quote": round(base_cost, 2),
      "current_fcf_rate": fcf_rate, "notes": "Costo base incluye 30% de contribución (mock)."
    }

    callback_url = f"http://127.0.0.1:5003/api/commercial/costing-parameters/{quote_id}"
    try:
        requests.post(callback_url, json=mock_response, timeout=5)
    except requests.exceptions.RequestException as e:
        print(f"Mock-Finance: Could not call back Commercial Agent. Error: {e}")

    return jsonify({"message": "Costing request received by mock Finance. Processing..."}), 202
