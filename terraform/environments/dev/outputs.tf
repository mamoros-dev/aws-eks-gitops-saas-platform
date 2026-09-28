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

# ==============================================================================
# Output values for the RDS PostgreSQL Module
# ==============================================================================

output "rds_hostname" {
  value       = aws_db_instance.postgres.address
  description = "The hostname/endpoint of the RDS PostgreSQL instance / Hostname del endpoint de RDS"
}

output "rds_port" {
  value       = aws_db_instance.postgres.port
  description = "The port on which the RDS PostgreSQL instance accepts connections / Puerto de conexion a RDS"
}

output "rds_db_name" {
  value       = aws_db_instance.postgres.db_name
  description = "The name of the initial database / Nombre de la base de datos inicial"
}

output "rds_secret_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "ARN of the Secrets Manager secret holding DB credentials / ARN del secreto en Secrets Manager"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "ID of the Security Group attached to RDS / ID del Security Group de RDS"
}