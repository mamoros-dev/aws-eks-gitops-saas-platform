# ==============================================================================
# Environment / Entorno: terraform/environments/prod/variables.tf
# Description: Variable definitions for Production Environment
# Descripción: Definición de variables para el entorno de Produccion
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "AWS Region for deployment / Región de AWS para el despliegue"
  default     = "eu-west-1"
}

variable "project_name" {
  type        = string
  description = "Project name / Nombre del proyecto"
  default     = "saas-platform"
}

variable "environment" {
  type        = string
  description = "Environment name / Nombre del entorno"
  default     = "prod"
}
