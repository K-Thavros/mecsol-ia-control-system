from app.models.in_memory_db import leads_db

def qualify_lead(lead_id, weights=None):
    """Calcula el LeadScore para un lead y lo actualiza."""
    lead = leads_db.get(lead_id)
    if not lead:
        return None

    if weights is None:
        weights = {'w_icp': 0.5, 'w_intent': 0.4, 'w_eng': 0.1}

    criteria = lead.get('criteria', {})
    lead_score = (weights['w_icp'] * criteria.get('icp', 0)) + \
                 (weights['w_intent'] * criteria.get('intent', 0)) + \
                 (weights['w_eng'] * criteria.get('engagement', 0))
    
    lead['score'] = round(lead_score, 2)

    mql_threshold = 75
    if lead_score > mql_threshold:
        lead['status'] = 'MQL'
    else:
        lead['status'] = 'QUALIFIED_OUT'

    leads_db[lead_id] = lead
    return lead
