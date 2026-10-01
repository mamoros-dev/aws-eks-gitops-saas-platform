# ==============================================================================
# Security Module Variables / Variables del Módulo de Seguridad
# ==============================================================================

variable "project_name" {
  description = "Project name / Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Deployment environment / Entorno de despliegue (ej. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "Target VPC ID for Flow Logs / ID de la VPC destino para Flow Logs"
  type        = string
}
