from fastapi import FastAPI
import os

app = FastAPI(
    title="MECSOL AI Orchestrator",
    version="0.1.0"
)

@app.get("/health", tags=["Monitoring"])
def read_root():
    """
    Health check endpoint. Returns the status of the service.
    """
    return {"status": "ok", "service": "Orchestrator"}

@app.get("/config", tags=["Monitoring"])
def read_config():
    """
    Returns the current environment setting for verification.
    WARNING: Do not expose sensitive variables here.
    """
    return {"environment": os.getenv("ENVIRONMENT", "not-set")}
