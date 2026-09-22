# ==============================================================================
# Environment / Entorno: terraform/environments/dev/main.tf
# Description: Main entry point for Development Infrastructure
# Descripción: Punto de entrada principal para la infraestructura de Desarrollo
# ==============================================================================

# Configuración del Proveedor AWS / AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SaaS-Platform"
      Environment = "dev"
      Owner       = "Miguel Amoros"
      ManagedBy   = "Terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. Módulo de Red (VPC) / Network Module (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  # Indicate the relative path to the template/module we created earlier
  # Indicamos la ruta relativa hacia la plantilla/módulo que creamos antes
  source = "../../modules/vpc"

  # Add the essential parameters for the enviornemnt dev
  # Pasamos los parámetros específicos para el entorno de Desarrollo
  environment        = "dev"
  vpc_name           = "saas-platform-dev-vpc"
  vpc_cidr           = "10.0.0.0/16"
  cluster_name       = "saas-platform-dev-eks"
  availability_zones = ["eu-west-1a", "eu-west-1b"]

  # Subredes / Subnets
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  # FinOps: On Dev we use a single NAT Gateway to save AWS costs
  #FinOps: En Dev usamos 1 solo NAT Gateway para ahorrar costes de AWS
  single_nat_gateway = true
}