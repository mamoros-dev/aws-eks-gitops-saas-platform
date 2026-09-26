resource "kubernetes_ingress_v1" "argocd_alb" {
  depends_on = [
    helm_release.argocd,
    helm_release.aws_lb_controller
  ]

  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
    annotations = {
      # Specifies that the Ingress must be managed by the AWS Load Balancer Controller / Especifica que el Ingress debe ser gestionado por AWS Load Balancer Controller
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      
      # Listener en puerto 80 (HTTP) externamente sin requerir ACM Certificate
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"

      # Comunicación interna del ALB con los Pods de ArgoCD (HTTP en port 8080/80)
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"

      # Healthcheck apuntando al endpoint HTTP /healthz de ArgoCD
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}