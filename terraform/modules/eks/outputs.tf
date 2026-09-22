# ==============================================================================
# Module / Módulo: terraform/modules/eks/outputs.tf
# Description: Output values exported by the EKS module
# Descripción: Valores de salida exportados por el módulo EKS
# ==============================================================================

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster / El nombre del clúster EKS"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for EKS control plane / Endpoint de conexión al control plane"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security group ID attached to the EKS cluster / ID del grupo de seguridad del clúster"
}
