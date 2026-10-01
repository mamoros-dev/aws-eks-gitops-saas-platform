# ===============================================================================
# Application: SaaS Backend API / API de Backend SaaS
# Description: Minimal FastAPI service returning health and environment info
# ===============================================================================

# Import necessary libraries / Importar bibliotecas necesarias
import json
import logging
import os
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import Depends, FastAPI, HTTPException, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from prometheus_fastapi_instrumentator import Instrumentator
from sqlalchemy import text
from sqlalchemy.orm import Session

# Import connections generator to DB / Importar el generador de conexiones a la BD
from app.database import get_db

# Import DB generator, base engine, and data model / Importar generador de DB, motor base y modelo de datos
from app.database import get_db, Base, engine
from app.models import Tenant

# Logger setup / Configuración de logs
logger = logging.getLogger("uvicorn.error")

# ------------------------------------------------------------------------------
# AWS SQS Configuration / Configuración de AWS SQS
# ------------------------------------------------------------------------------
SQS_QUEUE_URL = os.getenv("SQS_QUEUE_URL")
AWS_REGION = os.getenv("AWS_REGION", "eu-west-1")

# Initialize SQS client (boto3 automatically resolves IRSA WebIdentity credentials)
# Inicializar el cliente SQS (boto3 resuelve automáticamente las credenciales IRSA)
sqs_client = boto3.client("sqs", region_name=AWS_REGION)


def send_sqs_event(event_type: str, payload: dict):
    """
    Helper function to publish messages to AWS SQS Queue.
    Función auxiliar para publicar mensajes en la cola de AWS SQS.
    """
    if not SQS_QUEUE_URL:
        logger.warning("SQS_QUEUE_URL is not set. Skipping event publication. / SQS_QUEUE_URL no está configurado.")
        return None

    message_body = {
        "event_type": event_type,
        "data": payload
    }

    try:
        response = sqs_client.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(message_body)
        )
        logger.info(f"Event '{event_type}' sent to SQS. MessageId: {response.get('MessageId')}")
        return response.get("MessageId")
    except (BotoCoreError, ClientError) as e:
        logger.error(f"Failed to send event '{event_type}' to SQS: {str(e)}")
        # Non-blocking error logging / Registro de error no bloqueante
        return None

# Create FastAPI application instance / Crear instancia de la aplicación FastAPI
app = FastAPI(
    title="SaaS Multi-Tenant API",
    version="6.0.0"
)

# Jinja2 HTML template engine configuration (app/templates directory) / Configuración del motor de plantillas HTML Jinja2 (Directorio app/templates)
templates = Jinja2Templates(directory="app/templates")

# Automatic instrumentation to expose standard Prometheus metrics (/metrics)
# Instrumentación automática para exponer métricas estándar de Prometheus (/metrics)
Instrumentator().instrument(app).expose(app)

# Evento de inicio: Crea las tablas de forma segura cuando la app arranca
@app.on_event("startup")
def startup_db_client():
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Warning: Could not connect to DB on startup: {e}")

# ------------------------------------------------------------------------------
# NEW: Main Route (Dashboard HTML / UI)
# Renders the visual dashboard by reading the list of tenants directly from RDS
# NUEVO: Ruta Principal (Dashboard HTML / UI)
# Renderiza el panel visual leyendo la lista de tenants directamente de RDS
# ------------------------------------------------------------------------------
@app.get("/", response_class=HTMLResponse)
def read_root_ui(request: Request, db: Session = Depends(get_db)):
    """
    Query all tenants stored in Amazon RDS PostgreSQL
    and render the Jinja2 HTML template.
    Consulta todos los Tenants almacenados en Amazon RDS PostgreSQL
    y renderiza la plantilla HTML Jinja2.
    """
    tenants = db.query(Tenant).order_by(Tenant.id.desc()).all()
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "tenants": tenants,
            "environment": os.getenv("ENVIRONMENT", "dev"),
            "app_name": os.getenv("APP_NAME", "SaaS Platform")
        }
    )


# ------------------------------------------------------------------------------
# NEW: POST endpoint to create a tenant from the web form / NUEVO: Endpoint POST para crear un Tenant desde el formulario Web
# ------------------------------------------------------------------------------
@app.post("/tenants/create")
def create_tenant_form(
    name: str = Form(...),
    subdomain: str = Form(...),
    plan: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Receives the HTML form data, saves the entity to Amazon RDS, and sends an event to AWS SQS.
    Recibe los datos del formulario HTML, guarda la entidad en Amazon RDS y envía un evento a AWS SQS.
    """
    # Check if the subdomain already exists in RDS / Comprobar si el subdominio ya existe en RDS
    existing = db.query(Tenant).filter(Tenant.subdomain == subdomain).first()
    if existing:
        raise HTTPException(status_code=400, detail="The subdomain already exists in RDS / El subdominio ya existe en RDS")

    new_tenant = Tenant(name=name, subdomain=subdomain, plan=plan)
    db.add(new_tenant)
    db.commit()
    db.refresh(new_tenant)

    # Publish tenant created event to SQS / Publicar evento de tenant creado en SQS
    send_sqs_event(
        event_type="TENANT_CREATED",
        payload={
            "tenant_id": new_tenant.id,
            "name": new_tenant.name,
            "subdomain": new_tenant.subdomain,
            "plan": new_tenant.plan,
            "is_active": new_tenant.is_active
        }
    )

    # Redirects to the visual dashboard to view the updated record / Redirige al Dashboard visual para ver el registro actualizado
    return RedirectResponse(url="/", status_code=303)


# ------------------------------------------------------------------------------
# NEW: POST endpoint to delete an RDS Tenant / NUEVO: Endpoint POST para eliminar un Tenant de RDS
# ------------------------------------------------------------------------------
@app.post("/tenants/delete/{tenant_id}")
def delete_tenant_form(tenant_id: int, db: Session = Depends(get_db)):
    """
    Deletes a record from the 'tenants' table in Amazon RDS by ID and publishes the event to SQS.
    Elimina un registro de la tabla 'tenants' en Amazon RDS por ID y publica el evento en SQS.
    """
    tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if tenant:
        # Save details for the event before deletion / Guardar detalles para el evento antes de borrar
        deleted_data = {
            "tenant_id": tenant.id,
            "name": tenant.name,
            "subdomain": tenant.subdomain
        }

        db.delete(tenant)
        db.commit()

        # Publish tenant deleted event to SQS / Publicar evento de tenant eliminado en SQS
        send_sqs_event(
            event_type="TENANT_DELETED",
            payload=deleted_data
        )

    return RedirectResponse(url="/", status_code=303)


# ------------------------------------------------------------------------------
# Health Endpoints and REST API unchanged / Endpoints de Salud y API REST sin cambios
# ------------------------------------------------------------------------------
@app.get("/healthz", status_code=200)
def healthz():
    """Ultra-fast endpoint exclusively for Kubernetes probes / Endpoint ultra-rápido solo para probes de Kubernetes"""
    return {"status": "ok"}

@app.get("/health/db")
def health_check_db(db: Session = Depends(get_db)):
    try:
        result = db.execute(text("SELECT 1")).scalar()
        if result == 1:
            return {"status": "healthy", "database": "connected", "engine": "PostgreSQL"}
        raise HTTPException(status_code=500, detail="Database query failed")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
