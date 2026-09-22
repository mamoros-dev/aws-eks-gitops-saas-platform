# ==============================================================================
# Environment / Entorno: terraform/environments/dev/variables.tf
# Description: Variable definitions for Development Environment
# Descripción: Definición de variables para el entorno de Desarrollo
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "AWS Region for deployment / Región de AWS para el despliegue"
  default     = "eu-west-1"
}