import os
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from pydantic import BaseModel

# --- Configuración ---
# Lee el secreto JWT desde una variable de entorno. ¡Nunca hardcodear secretos!
JWT_SECRET = os.environ.get("JWT_SECRET")
ALGORITHM = "HS256"

if not JWT_SECRET:
    raise ValueError("La variable de entorno JWT_SECRET no está configurada.")

# --- Inicialización de FastAPI ---
app = FastAPI(
    title="MECSOL AI Orchestrator",
    description="Núcleo de inteligencia que coordina los servicios del departamento de ventas autónomo.",
    version="1.0.0",
)

# --- Seguridad (Autenticación con JWT) ---
# Define el esquema de autenticación. "tokenUrl" es el endpoint para obtener el token.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Dependencia que valida el token JWT y devuelve el payload del usuario.
    Esto protegerá los endpoints que la usen.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        # Aquí se podría buscar el usuario en la base de datos si fuera necesario
        return {"username": username}
    except JWTError:
        raise credentials_exception

# --- Modelos de Datos (Pydantic) ---
# Definen la estructura de los datos para request y response.
class HealthCheck(BaseModel):
    status: str

class ApiResponse(BaseModel):
    message: str
    reference_id: str

# --- Endpoints de la API ---

@app.get("/health", response_model=HealthCheck, tags=["System"])
async def health_check():
    """
    Endpoint de monitoreo para verificar que el servicio está activo.
    """
    return {"status": "ok"}

@app.post("/optimize/leads", response_model=ApiResponse, tags=["Optimization"])
async def optimize_leads(user: dict = Depends(get_current_user)):
    """
    (Simulado) Inicia un proceso de optimización de leads.
    Requiere autenticación.
    """
    # Aquí iría la lógica para llamar a n8n o algoritmos internos
    return {"message": "Proceso de optimización de leads iniciado.", "reference_id": "opt_lead_12345"}

@app.post("/optimize/proyectos", response_model=ApiResponse, tags=["Optimization"])
async def optimize_proyectos(user: dict = Depends(get_current_user)):
    """
    (Simulado) Inicia un proceso de optimización de proyectos.
    Requiere autenticación.
    """
    # Lógica de optimización de recursos, tiempos, etc.
    return {"message": "Proceso de optimización de proyectos iniciado.", "reference_id": "opt_proj_67890"}

@app.post("/marketing/content", response_model=ApiResponse, tags=["Marketing"])
async def marketing_content(user: dict = Depends(get_current_user)):
    """
    (Simulado) Solicita la generación de contenido de marketing a un agente IA.
    Requiere autenticación.
    """
    # Lógica para interactuar con agentes OpenAI
    return {"message": "Generación de contenido de marketing iniciada.", "reference_id": "mkt_cont_abcde"}

@app.post("/support/triage", response_model=ApiResponse, tags=["Support"])
async def support_triage(user: dict = Depends(get_current_user)):
    """
    (Simulado) Realiza el triaje de un ticket de soporte entrante.
    Requiere autenticación.
    """
    # Lógica para clasificar y responder tickets automáticamente
    return {"message": "Triaje de ticket de soporte iniciado.", "reference_id": "sup_tic_fghij"}

# --- Endpoint de prueba para generar un token ---
class Token(BaseModel):
    access_token: str
    token_type: str

@app.post("/token", response_model=Token, tags=["System"])
async def login_for_access_token():
    """
    Endpoint de prueba para generar un token JWT.
    En una aplicación real, verificaría usuario y contraseña.
    """
    # El "subject" del token puede ser un ID de usuario o un identificador de servicio
    to_encode = {"sub": "internal_service_user"}
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET, algorithm=ALGORITHM)
    return {"access_token": encoded_jwt, "token_type": "bearer"}
