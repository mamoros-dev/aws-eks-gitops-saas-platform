# ==============================================================================
# Module / Módulo: terraform/modules/eks/main.tf
# Description: Provisions Managed Amazon EKS Cluster and Worker Node Groups
# Descripción: Aprovisiona el clúster gestionado Amazon EKS y grupo de nodos
# ==============================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network Security: The EKS API Server will be accessible from outside,
  # but the Worker Nodes will be strictly and only in Private Subnets.
  # Seguridad de Red: El Servidor API de EKS será accesible desde el exterior,
  # pero los Nodos de Trabajo estarán estrictamente y solo en Subredes Privadas
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # Options for granting admin access to the identity running Terraform
  # Opciones para otorgar acceso de administración a la identidad que ejecuta Terraform
  enable_cluster_creator_admin_permissions = true

  # Configuración de Security Groups para comunicación EKS <-> Nodos
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  # Managed Node Groups (EC2 Instances)
  # Grupo de Nodos Gestionados (EC2 Instances)
  eks_managed_node_groups = {
    nodes = {
      # exceed lenght limit of 32 characters for the name of the node group
      #name           = "${var.cluster_name}-node-group"
      name            = "node-group-dev"
      use_name_prefix = false

      # Amazon Linux 2023 with EKS 1.32
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # FinOps: We use SPOT instances in Dev if desired, or standard ON_DEMAND
      # FinOps: Usamos instancias SPOT en Dev si se desea, o ON_DEMAND estándar
      capacity_type = var.capacity_type
    }
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ==============================================================================
# AWS Load Balancer Controller - IAM Policy & IRSA Role
# ==============================================================================

# 1. Official IAM Policy for AWS Load Balancer Controller
# 1. Política de IAM oficial para AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${var.cluster_name}-aws-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws_lb_controller_policy.json")
}

# 2. IAM Role associated with the OIDC Provider (IRSA)
# 2. IAM Role asociado al OIDC Provider (IRSA)
module "aws_lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name                              = "${var.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}
