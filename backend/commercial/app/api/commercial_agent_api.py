import uuid
from datetime import datetime
from flask import Blueprint, request, jsonify

from app.models.in_memory_db import leads_db, quotes_db, projects_db
from app.services import lead_service, quote_service, funnel_service

commercial_bp = Blueprint('commercial_api', __name__)

# --- Rutas para Leads ---

@commercial_bp.route('/leads', methods=['POST'])
def create_lead():
    data = request.get_json()
    if not data or 'source' not in data or 'details' not in data:
        return jsonify({"error": "Missing data: 'source' and 'details' are required"}), 400

    lead_id = f"lead-{uuid.uuid4().hex[:6]}"
    leads_db[lead_id] = {
        "id": lead_id, "source": data['source'], "details": data['details'],
        "criteria": data.get('criteria', {"icp": 50, "intent": 50, "engagement": 10}),
        "score": 0, "status": "PRELIMINARY", "created_at": datetime.utcnow().isoformat()
    }
    return jsonify(leads_db[lead_id]), 201

@commercial_bp.route('/leads/<string:lead_id>/qualify', methods=['POST'])
def qualify_single_lead(lead_id):
    lead = lead_service.qualify_lead(lead_id)
    if not lead:
        return jsonify({"error": "Lead not found"}), 404
    return jsonify(lead), 200

# --- Rutas para Cotizaciones (Quotes) ---

@commercial_bp.route('/quotes', methods=['POST'])
def create_quote():
    data = request.get_json()
    if not data or 'lead_id' not in data or 'operations_payload' not in data or 'finance_payload' not in data:
        return jsonify({"error": "Missing lead_id, operations_payload, or finance_payload"}), 400

    quote_id = f"QT-{datetime.utcnow().year}-{uuid.uuid4().hex[:4].upper()}"
    quotes_db[quote_id] = {
        "id": quote_id, "lead_id": data['lead_id'], "status": "DRAFT",
        "operations_check": {"request_id": quote_id, "response": None},
        "finance_check": {"response": None}, "created_at": datetime.utcnow().isoformat()
    }

    quote_service.initiate_quote_process(quote_id, data)
    return jsonify({"message": "Quote process initiated", "quote_id": quote_id}), 202

@commercial_bp.route('/quotes/<string:quote_id>', methods=['GET'])
def get_quote_status(quote_id):
    quote = quotes_db.get(quote_id)
    if not quote:
        return jsonify({"error": "Quote not found"}), 404
    return jsonify(quote), 200

# --- Rutas de Callback para otros Agentes ---

@commercial_bp.route('/costing-parameters/<string:quote_id>', methods=['POST'])
def receive_costing_parameters(quote_id):
    data = request.get_json()
    success, message = quote_service.process_finance_response(quote_id, data)
    if not success:
        return jsonify({"error": message}), 404
    return jsonify({"message": message}), 200

@commercial_bp.route('/capacity-check-response/<string:request_id>', methods=['POST'])
def receive_capacity_response(request_id):
    data = request.get_json()
    success, message = quote_service.process_operations_response(request_id, data)
    if not success:
        return jsonify({"error": message}), 404
    return jsonify({"message": message}), 200

# --- Rutas para el Funnel de Ventas ---

@commercial_bp.route('/funnel/kpis', methods=['GET'])
def get_kpis():
    kpis = funnel_service.get_funnel_kpis()
    return jsonify(kpis), 200
