# ==============================================================================
# Module / Módulo: terraform/modules/ecr/variables.tf
# Description: Input variables for the ECR module
# Descripción: Variables de entrada para el módulo ECR
# ==============================================================================

variable "repository_name" {
  type        = string
  description = "Name of the ECR repository / Nombre del repositorio ECR"
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability (MUTABLE or IMMUTABLE) / Inmutabilidad de etiquetas"
  default     = "MUTABLE" # En Dev usaremos MUTABLE para iterar rápido; en Prod usaremos IMMUTABLE
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod) / Nombre del entorno (dev/prod)"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags / Etiquetas de recursos"
  default     = {}
}
