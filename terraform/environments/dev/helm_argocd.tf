# ==============================================================================
# File / Archivo: terraform/environments/dev/helm_argocd.tf
# Description: Deployment of ArgoCD via Helm Chart for GitOps management
# ==============================================================================

# 1. Create the dedicated namespace for ArgoCD
# 1. Crear el Namespace dedicado para ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# 2. Deploy the official Helm chart for ArgoCD
# 2. Despliegue del Chart oficial de Helm para ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "6.7.11"

  timeout = 900
  wait    = true

  # Basic config for ArgoCD webserver
  # Configuración básica para el servidor web de ArgoCD
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Allow HTTP access without secure cookie restrictions (Dev environment)
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  depends_on = [
    module.eks,
    kubernetes_namespace.argocd
  ]
}
