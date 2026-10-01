# ==============================================================================
# Environment / Entorno: terraform/environments/dev/main.tf
# Description: Main entry point for Development Infrastructure
# Descripción: Punto de entrada principal para la infraestructura de Desarrollo
# ==============================================================================

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

# ------------------------------------------------------------------------------
# 2. Módulo de Registro de Contenedores (ECR) / Container Registry Module (ECR)
# ------------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  environment          = "dev"
  repository_name      = "saas-platform-dev-api"
  image_tag_mutability = "MUTABLE" # only in dev we use mutable tags to speed up testing / Solo en Dev usamos tags mutables para agilizar pruebas
  force_delete         = true
}

# ------------------------------------------------------------------------------
# 3. Módulo de Kubernetes (EKS) / Kubernetes Cluster Module (EKS)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  environment     = "dev"
  cluster_name    = "saas-platform-dev-eks"
  cluster_version = "1.32"

  # Dynamic connection with the outputs of the VPC module / Conexión dinámica con los outputs del módulo VPC
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Node configuration for the Dev environment (FinOps: 3 nodes t3.small) / Configuración de nodos para el entorno Dev (FinOps: 3 nodos t3.small)
  instance_types = ["t3.small"]
  min_size       = 3
  max_size       = 4
  desired_size   = 3
}
