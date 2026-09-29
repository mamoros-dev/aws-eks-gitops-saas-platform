# ==============================================================================
# Module / Módulo: src/app/database.py
# Description: PostgreSQL Database connection setup using SQLAlchemy
# Descripción: Configuración de conexión a PostgreSQL usando SQLAlchemy
# ==============================================================================
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# ------------------------------------------------------------------------------
# 1. Lectura de Variables de Entorno / Environment Variables Lookup
# ------------------------------------------------------------------------------
DB_ENGINE = os.getenv("DB_ENGINE", "postgres")
DB_USER = os.getenv("DB_USER", "dbadmin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "appdb")

# ------------------------------------------------------------------------------
# 2. Construcción de la URL de PostgreSQL / Database Connection String
# Result: postgresql://dbadmin:mi_password@saas-platform-dev-db...:5432/appdb
# ------------------------------------------------------------------------------
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# ------------------------------------------------------------------------------
# 3. Motor de SQLAlchemy y Sesión / Engine & Session Generator
# ------------------------------------------------------------------------------
engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 3})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


# Dependency para inyectar la sesión en los endpoints de FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
