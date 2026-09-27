# ==============================================================================
# Application: SaaS Backend API / API de Backend SaaS
# Description: Minimal FastAPI service returning health and environment info
# ==============================================================================

# Import necessary libraries / Importar bibliotecas necesarias
import os
from fastapi import FastAPI

# Create FastAPI application instance / Crear instancia de la aplicación FastAPI
app = FastAPI(
    title="SaaS Multi-Tenant API",
    version="2.0.0"
)

# Health check endpoint used by Kubernetes (Liveness/Readiness Probes)
# Endpoint de salud (Health Check) usado por Kubernetes (Liveness/Readiness Probes)
@app.get("/")
def read_root():
    return {
        "status": "healthy",
        "app_name": os.getenv("APP_NAME", "SaaS App"),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "version": "v2.0.0",
        "message": "SaaS Platform API v2.0.0 running on AWS EKS with GitOps!",
    }

# Route for health check used by Kubernetes (Liveness/Readiness Probes)
# Ruta para el health check usado por Kubernetes (Liveness/Readiness Probes)
@app.get("/healthz")
def health_check():
    return {"status": "ok", "version": "v2.0.0"}