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
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"

      # Associate ACM certificate / Asociamos el certificado de ACM
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.argocd_acm.arn

      # Listener en puerto 80 (HTTP) externamente sin requerir ACM Certificate
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"

      # 3. Automatic redirection from HTTP to HTTPS / Redirección automática de HTTP a HTTPS
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"

      # Internal ALB communication with ArgoCD pods (HTTP on port 80) / Comunicación interna del ALB con los Pods de ArgoCD (HTTP en port 80)
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"

      # Health check pointing to the ArgoCD HTTP /healthz endpoint / Healthcheck apuntando al endpoint HTTP /healthz de ArgoCD
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
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
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
