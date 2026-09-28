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

# Create FastAPI application instance / Crear instancia de la aplicación FastAPI
app = FastAPI(
    title="SaaS Multi-Tenant API",
    version="4.0.0"
)

# Automatic instrumentation to expose standard Prometheus metrics (/metrics)
# Instrumentación automática para exponer métricas estándar de Prometheus (/metrics)
Instrumentator().instrument(app).expose(app)


# Health check endpoint used by Kubernetes (Liveness/Readiness Probes)
# Endpoint de salud (Health Check) usado por Kubernetes (Liveness/Readiness Probes)
@app.get("/")
def read_root():
    return {
        "status": "healthy",
        "app_name": os.getenv("APP_NAME", "SaaS App"),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "version": "v4.0.0",
        "message": "SaaS Platform API v4.0.0 with RDS Database running on AWS EKS with GitOps!",
    }

# Route for health check used by Kubernetes (Liveness/Readiness Probes)
# Ruta para el health check usado por Kubernetes (Liveness/Readiness Probes)
@app.get("/healthz")
def health_check():
    return {"status": "ok", "version": "v4.0.0"}

# ------------------------------------------------------------------------------
# NEW: Dedicated Database Health Check Endpoint
# Ruta dedicada para verificar la conectividad real con Amazon RDS PostgreSQL
# ------------------------------------------------------------------------------
@app.get("/health/db")
def health_check_db(db: Session = Depends(get_db)):
    """
    Verifica la conexión ejecutando 'SELECT 1' en RDS PostgreSQL.
    Depends(get_db) inyecta y cierra automáticamente la sesión de la base de datos.
    """
    try:
        result = db.execute(text("SELECT 1")).scalar()
        if result == 1:
            return {
                "status": "healthy",
                "database": "connected",
                "engine": "PostgreSQL"
            }
        raise HTTPException(status_code=500, detail="Database query failed")
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Database connection failed: {str(e)}"
        )