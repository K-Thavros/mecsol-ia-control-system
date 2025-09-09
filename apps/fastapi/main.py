import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, Any

# ===================================================================
# Modelos de Datos (Pydantic)
# ===================================================================

class Lead(BaseModel):
    source: str = Field(..., description="Origen del lead, ej: 'website_form', 'social_media'")
    contact_email: str = Field(..., description="Email de contacto del lead")
    details: Dict[str, Any] = Field(..., description="Detalles flexibles del lead, como tipo de maquinaria, etc.")

# ===================================================================
# Aplicación FastAPI
# ===================================================================

app = FastAPI(
    title="MECSOL AI Orchestrator",
    version="1.0.0",
    description="Orquestador central para el sistema de ventas automatizado de MECSOL."
)

# ===================================================================
# Endpoints de la API
# ===================================================================

@app.get("/health", tags=["Monitoring"])
def read_health():
    """
    Endpoint de Health Check. Confirma que el servicio está en línea.
    """
    return {"status": "ok", "service": "MECSOL AI Orchestrator"}

@app.post("/v1/lead/intake", tags=["Leads"])
def intake_lead(lead: Lead):
    """
    Endpoint para la ingesta de nuevos leads.
    Aquí es donde se iniciará la lógica de negocio:
    1. Guardar el lead en la base de datos.
    2. Usar un algoritmo para asignar el lead a un agente de IA.
    3. Iniciar el proceso de contacto del agente.
    """
    print(f"Lead recibido de {lead.source}: {lead.contact_email}")
    print(f"Detalles: {lead.details}")

    # --- Lógica de negocio (a implementar) ---
    # 1. Almacenar en BBDD
    # 2. Asignar agente
    # 3. Retornar un ID de seguimiento
    # -----------------------------------------

    lead_id = "lead_" + os.urandom(8).hex() # ID de ejemplo

    return {
        "status": "success",
        "message": "Lead recibido y siendo procesado.",
        "tracking_id": lead_id
    }
