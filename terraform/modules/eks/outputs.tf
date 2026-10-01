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

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "aws_lb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.aws_lb_controller_irsa.iam_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA / ARN del proveedor OIDC para IRSA"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "The URL of the OIDC Issuer for IRSA / URL del emisor OIDC para IRSA"
  value       = module.eks.oidc_provider
}
