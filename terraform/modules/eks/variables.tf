# ==============================================================================
# Module / Módulo: terraform/modules/eks/variables.tf
# Description: Input variables for the EKS module
# Descripción: Variables de entrada para el módulo EKS
# ==============================================================================

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster / Nombre del clúster EKS"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version / Versión de Kubernetes"
  default     = "1.30"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be deployed / ID de la VPC para EKS"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for EKS worker nodes / Subredes privadas para nodos"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 Instance types for worker nodes / Tipos de instancia EC2 para los nodos"
  default     = ["t3.medium"] # t3.medium es el tamaño mínimo recomendado para Kubernetes con Prometheus/ArgoCD / t3.medium is the minimum recommended size for Kubernetes with Prometheus/ArgoCD
}

variable "min_size" {
  type        = number
  description = "Minimum number of nodes / Número mínimo de nodos"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of nodes / Número máximo de nodos"
  default     = 3
}

variable "desired_size" {
  type        = number
  description = "Desired number of nodes / Número deseado de nodos"
  default     = 2
}

variable "capacity_type" {
  type        = string
  description = "Capacity type: ON_DEMAND or SPOT / Tipo de capacidad"
  default     = "ON_DEMAND"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod) / Nombre del entorno"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags / Etiquetas de recursos"
  default     = {}
}
