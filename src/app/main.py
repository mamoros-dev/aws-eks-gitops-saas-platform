# ==============================================================================
# Application: SaaS Backend API / API de Backend SaaS
# Description: Minimal FastAPI service returning health and environment info
# ==============================================================================

# Import necessary libraries / Importar bibliotecas necesarias
import os
from fastapi import Depends, FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator
from sqlalchemy import text
from sqlalchemy.orm import Session
# Import connections generator to DB / Importar el generador de conexiones a la BD
from app.database import get_db

# Import DB generator, base engine, and data model / Importar generador de DB, motor base y modelo de datos
from app.database import get_db, Base, engine
from app.models import Tenant

# CCreate tables in Amazon RDS if they do not already exist / rear tablas en Amazon RDS si no existen previamente
Base.metadata.create_all(bind=engine)

# Create FastAPI application instance / Crear instancia de la aplicación FastAPI
app = FastAPI(
    title="SaaS Multi-Tenant API",
    version="5.0.0"
)

# Jinja2 HTML template engine configuration (app/templates directory) / Configuración del motor de plantillas HTML Jinja2 (Directorio app/templates)
templates = Jinja2Templates(directory="app/templates")

# Automatic instrumentation to expose standard Prometheus metrics (/metrics)
# Instrumentación automática para exponer métricas estándar de Prometheus (/metrics)
Instrumentator().instrument(app).expose(app)


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
        "dashboard.html",
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
    Receives the HTML form data and saves the entity to Amazon RDS.
    Recibe los datos del formulario HTML y guarda la entidad en Amazon RDS.
    """
    # Check if the subdomain already exists in RDS / Comprobar si el subdominio ya existe en RDS
    existing = db.query(Tenant).filter(Tenant.subdomain == subdomain).first()
    if existing:
        raise HTTPException(status_code=400, detail="The subdomain already exists in RDS / El subdominio ya existe en RDS")

    new_tenant = Tenant(name=name, subdomain=subdomain, plan=plan)
    db.add(new_tenant)
    db.commit()
    
    # Redirects to the visual dashboard to view the updated record / Redirige al Dashboard visual para ver el registro actualizado
    return RedirectResponse(url="/", status_code=303)


# ------------------------------------------------------------------------------
# NEW: POST endpoint to delete an RDS Tenant / NUEVO: Endpoint POST para eliminar un Tenant de RDS
# ------------------------------------------------------------------------------
@app.post("/tenants/delete/{tenant_id}")
def delete_tenant_form(tenant_id: int, db: Session = Depends(get_db)):
    """
    Elimina un registro de la tabla 'tenants' en Amazon RDS por ID.
    """
    tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if tenant:
        db.delete(tenant)
        db.commit()
    return RedirectResponse(url="/", status_code=303)


# ------------------------------------------------------------------------------
# Health Endpoints and REST API unchanged / Endpoints de Salud y API REST sin cambios
# ------------------------------------------------------------------------------
@app.get("/healthz")
def health_check():
    return {"status": "ok", "version": "v5.0.0"}

@app.get("/health/db")
def health_check_db(db: Session = Depends(get_db)):
    try:
        result = db.execute(text("SELECT 1")).scalar()
        if result == 1:
            return {"status": "healthy", "database": "connected", "engine": "PostgreSQL"}
        raise HTTPException(status_code=500, detail="Database query failed")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")