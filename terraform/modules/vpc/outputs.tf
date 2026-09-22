# ==============================================================================
# Module / Módulo: terraform/modules/vpc/outputs.tf
# Description: Output values exported by the VPC module
# Descripción: Valores de salida exportados por el módulo VPC
# ==============================================================================

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC / El ID de la VPC"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "List of IDs of private subnets / Lista de IDs de subredes privadas"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "List of IDs of public subnets / Lista de IDs de subredes públicas"
}