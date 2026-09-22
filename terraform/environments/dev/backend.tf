# ==============================================================================
# File / Archivo: terraform/environments/dev/backend.tf
# Description: Remote state backend configuration using S3 and DynamoDB
# Descripción: Configuración del backend de estado remoto usando S3 y DynamoDB
# ==============================================================================

terraform {
  # Especific minimum required version of Terraform
  # Especificamos la versión mínima de Terraform requerida
  required_version = ">= 1.5.0"

  # Declare the required providers (AWS in this case)
  # Declaramos los proveedores necesarios (AWS en este caso)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuration for remote state storage in S3
  # Configuración del estado remoto en S3
  backend "s3" {
    bucket         = "miguel-terraform-state-proyecto2"
    key            = "saas-platform/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks-proyecto2"
    encrypt        = true
  }
}