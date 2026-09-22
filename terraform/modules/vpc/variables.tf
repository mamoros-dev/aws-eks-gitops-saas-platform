# ==============================================================================
# Module / Módulo: terraform/modules/vpc/variables.tf
# Description: Input variables for the VPC module
# Descripción: Variables de entrada para el módulo VPC
# ==============================================================================

variable "vpc_name" {
  type        = string
  description = "Name of the VPC / Nombre de la VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC / Bloque CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones / Lista de Zonas de Disponibilidad"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets / Bloques CIDR para subredes públicas"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets / Bloques CIDR para subredes privadas"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Provision a single NAT Gateway to reduce costs / Un solo NAT Gateway para reducir costes"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster name for tagging / Nombre del clúster EKS para etiquetado"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod) / Nombre del entorno (dev/prod)"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags / Etiquetas de recursos"
  default     = {}
}