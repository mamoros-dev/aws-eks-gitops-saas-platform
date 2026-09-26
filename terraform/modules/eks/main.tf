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
  cluster_endpoint_public_access = true
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
      name            = "dev-node-group"
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
