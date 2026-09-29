# ==============================================================================
# Module / Módulo: terraform/modules/vpc/main.tf
# Description: Provisions Multi-AZ VPC with Public and Private Subnets for EKS
# Descripción: Aprovisiona VPC Multi-AZ con subredes públicas y privadas para EKS
# ==============================================================================

module "vpc" {
  # Using the official verified AWS VPC module
  # Usamos el módulo oficial verificado de AWS para VPC
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  # Availability zones / Zonas de disponibilidad
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Configuration for Internet Gateway for private subnets / Configuración de Internet Gateway para subredes privadas
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway # FinOps: true en Dev para ahorrar costes / FinOps: true in Dev to save costs
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required by EKS for auto-discovery of Ingress/LoadBalancers / Etiquetas requeridas por EKS para el auto-descubrimiento de Ingress/LoadBalancers
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
