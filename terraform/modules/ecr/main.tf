# ==============================================================================
# Module / Módulo: terraform/modules/ecr/main.tf
# Description: Provisions AWS ECR Repository with immutability and security scanning
# Descripción: Aprovisiona el Repositorio AWS ECR con inmutabilidad y escaneo de seguridad
# ==============================================================================

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Security scanning on image push / Escaneo automático de seguridad al subir imágenes
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encryption at rest / Cifrado en reposo
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Lifecycle Policy Rule: Delete old untagged images to save costs
# Regla de ciclo de vida (Lifecycle Policy): Elimina imágenes antiguas sin etiqueta para ahorrar costes
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 untagged images / Mantener las últimas 5 imágenes sin etiqueta"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
