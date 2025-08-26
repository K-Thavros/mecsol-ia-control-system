import requests
import threading
from flask import current_app

from app.models.in_memory_db import quotes_db

def initiate_quote_process(quote_id, quote_data):
    """Inicia llamadas asíncronas a los agentes de Operaciones y Finanzas."""
    def async_quote_processing():
        app = current_app._get_current_object()
        with app.app_context():
            # 1. Consultar a Operaciones
            try:
                op_url = f"{app.config['OPERATIONS_AGENT_URL']}/api/operations/capacity-check"
                payload = {"request_id": quote_id, **quote_data['operations_payload']}
                quotes_db[quote_id]['status'] = 'AWAITING_OPERATIONS'
                requests.post(op_url, json=payload, timeout=10)
            except requests.exceptions.RequestException as e:
                print(f"Error calling Operations Agent: {e}")
                quotes_db[quote_id]['status'] = 'ERROR_OPERATIONS'
                return

            # 2. Consultar a Finanzas
            try:
                fin_url = f"{app.config['FINANCE_AGENT_URL']}/api/finance/quote-costing-request"
                payload = {"quote_id": quote_id, **quote_data['finance_payload']}
                quotes_db[quote_id]['status'] = 'AWAITING_FINANCE'
                requests.post(fin_url, json=payload, timeout=10)
            except requests.exceptions.RequestException as e:
                print(f"Error calling Finance Agent: {e}")
                quotes_db[quote_id]['status'] = 'ERROR_FINANCE'
    
    thread = threading.Thread(target=async_quote_processing)
    thread.start()

def process_operations_response(request_id, response_data):
    """Procesa la respuesta del Agente de Operaciones."""
    quote = quotes_db.get(request_id)
    if not quote: return False, "Quote not found"
    
    quote['operations_check']['response'] = response_data
    check_and_calculate_price(request_id)
    return True, "Operations data received"

def process_finance_response(quote_id, response_data):
    """Procesa la respuesta del Agente de Finanzas."""
    quote = quotes_db.get(quote_id)
    if not quote: return False, "Quote not found"
        
    quote['finance_check']['response'] = response_data
    quote['base_cost_for_quote'] = response_data.get('base_cost_for_quote', 0)
    check_and_calculate_price(quote_id)
    return True, "Finance data received"

def check_and_calculate_price(quote_id):
    """Verifica si se tiene info de ambos agentes y calcula el precio."""
    quote = quotes_db.get(quote_id)
    if not quote or not (quote['operations_check'].get('response') and quote['finance_check'].get('response')):
        return

    quote['status'] = 'CALCULATING_PRICE'
    
    if not quote['operations_check']['response'].get('can_be_fulfilled', False):
        quote['status'] = 'REJECTED_CAPACITY'
        return

    base_cost = quote.get('base_cost_for_quote', 0)
    if base_cost <= 0:
        quote['status'] = 'ERROR_COSTING'
        return

    margen_base = 0.20
    precio_final = base_cost * (1 + margen_base)

    quote['final_price'] = round(precio_final, 2)
    quote['status'] = 'READY_TO_SEND'
    quotes_db[quote_id] = quote
