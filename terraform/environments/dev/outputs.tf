# ==============================================================================
# Environment / Entorno: terraform/environments/dev/outputs.tf
# Description: Output values for Development Environment
# Descripción: Valores de salida para el entorno de Desarrollo
# ==============================================================================

# Output values for the VPC module
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC / El ID de la VPC creada"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "IDs of the private subnets / IDs de las subredes privadas"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "IDs of the public subnets / IDs de las subredes públicas"
}

# Output values for the ECR module
output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "URL of the created ECR Repository / URL del repositorio ECR creado"
}

# Output values for the EKS module
output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS Cluster / Nombre del clúster EKS"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint URL of the EKS Cluster / URL del API Server de Kubernetes"
}