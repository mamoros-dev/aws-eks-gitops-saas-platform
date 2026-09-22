# ==============================================================================
# Module / Módulo: terraform/modules/ecr/outputs.tf
# Description: Output values exported by the ECR module
# Descripción: Valores de salida exportados por el módulo ECR
# ==============================================================================

output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "The URL of the repository / La URL del repositorio para hacer docker push"
}

output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "The ARN of the repository / El ARN del repositorio"
}
