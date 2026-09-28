# ==============================================================================
# File: app/models.py
# Description: SQLAlchemy ORM Models / Modelos de la Base de Datos PostgreSQL
# ==============================================================================

from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from app.database import Base

class Tenant(Base):
    """
    Represents a company or organization (Tenant Client) on the SaaS platform.
    Base.metadata will automatically create this table in Amazon RDS PostgreSQL.
    
    Representa una empresa u organización (Cliente Inquilino) en la plataforma SaaS.
    Base.metadata creará automáticamente esta tabla en Amazon RDS PostgreSQL.
    """
    __tablename__ = "tenants"

    # ID column: Auto-incrementing primary key / Columna ID: Clave primaria autoincremental
    id = Column(Integer, primary_key=True, index=True)
    
    # Customer name / Nombre del cliente
    name = Column(String(100), nullable=False)
    
    # Assigned subdomain / Subdominio asignado
    subdomain = Column(String(50), unique=True, nullable=False, index=True)
    
    # Subscription plan: "Basic", "Pro", "Enterprise" / Plan de suscripción: "Basic", "Pro", "Enterprise"
    plan = Column(String(20), default="Basic")
    
    # Tenant status (Active/Inactive) / Estado del tenant (Activo/Inactivo)
    is_active = Column(Boolean, default=True)
    
    # Automatic registration date in PostgreSQL / Fecha de registro automática en PostgreSQL
    created_at = Column(DateTime(timezone=True), server_default=func.now())