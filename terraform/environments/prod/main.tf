# ==============================================================================
# Environment / Entorno: terraform/environments/prod/main.tf
# Description: Main entry point for Production Infrastructure
# Descripción: Punto de entrada principal para la infraestructura de Produccion
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Módulo de Red (VPC) / Network Module (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  # Indicate the relative path to the template/module we created earlier
  # Indicamos la ruta relativa hacia la plantilla/módulo que creamos antes
  source = "../../modules/vpc"

  # Add the essential parameters for the enviornemnt prod
  # Pasamos los parámetros específicos para el entorno de Produccion
  environment        = "prod"
  vpc_name           = "saas-platform-prod-vpc"
  vpc_cidr           = "10.1.0.0/16"
  cluster_name       = "saas-platform-prod-eks"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  # Subredes / Subnets
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]

  # Production High Availability: Multiple NAT Gateways for fault tolerance
  # Alta Disponibilidad en Producción: NAT Gateways independientes por zona de disponibilidad
  single_nat_gateway = false
}

# ------------------------------------------------------------------------------
# 2. Módulo de Registro de Contenedores (ECR) / Container Registry Module (ECR)
# ------------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  environment          = "prod"
  repository_name      = "saas-platform-prod-api"
  image_tag_mutability = "IMMUTABLE" # Production security: tags cannot be overwritten / Seguridad en producción: los tags no se pueden sobrescribir
}

# ------------------------------------------------------------------------------
# 3. Módulo de Kubernetes (EKS) / Kubernetes Cluster Module (EKS)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  environment     = "prod"
  cluster_name    = "saas-platform-prod-eks"
  cluster_version = "1.32"

  # Dynamic connection with the outputs of the VPC module / Conexión dinámica con los outputs del módulo VPC
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Node configuration for the prod environment (FinOps: 2 nodes t3.medium) / Configuración de nodos para el entorno prod (FinOps: 2 nodos t3.medium)
  instance_types = ["t3.small"]
  min_size       = 3
  max_size       = 5
  desired_size   = 3
}
