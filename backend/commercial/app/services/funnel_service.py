from app.models.in_memory_db import quotes_db, leads_db

def get_funnel_kpis():
    """Calcula y devuelve los KPIs clave del embudo de ventas."""
    total_quotes = len(quotes_db)
    if total_quotes == 0:
        return {
            "conversion_rate_quote_to_win": 0, "deals_won": 0, "deals_lost": 0,
            "average_deal_size": 0, "total_quotes_sent": 0, "new_mqls": 0,
        }

    deals_won = [q for q in quotes_db.values() if q['status'] == 'WON']
    deals_lost = [q for q in quotes_db.values() if q['status'] == 'LOST']
    quotes_sent = [q for q in quotes_db.values() if q['status'] in ['SENT', 'WON', 'LOST']]
    
    num_won = len(deals_won)
    num_sent = len(quotes_sent)
    conversion_rate = (num_won / num_sent) if num_sent > 0 else 0
    
    total_value_won = sum(q.get('final_price', 0) for q in deals_won)
    average_deal_size = (total_value_won / num_won) if num_won > 0 else 0
    new_mqls = len([l for l in leads_db.values() if l['status'] == 'MQL'])

    return {
        "conversion_rate_quote_to_win": round(conversion_rate, 2),
        "deals_won": num_won, "deals_lost": len(deals_lost),
        "average_deal_size": round(average_deal_size, 2),
        "total_quotes_sent": num_sent, "new_mqls": new_mqls
    }
