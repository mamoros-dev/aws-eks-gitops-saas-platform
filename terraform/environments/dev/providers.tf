# ==============================================================================
# File / Archivo: terraform/environments/dev/providers.tf
# Description: Configuration for AWS, Kubernetes, and Helm providers
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

# Provider for communicating with the Kubernetes API
# Proveedor para comunicarse con la API de Kubernetes
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Provider for deploying Helm charts to the cluster
# Proveedor para desplegar Charts de Helm en el clúster
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}