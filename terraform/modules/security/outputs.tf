# ==============================================================================
# Security Module Outputs / Salidas del Módulo de Seguridad
# ==============================================================================

output "waf_web_acl_arn" {
  description = "ARN of WAFv2 WebACL for Ingress annotation / ARN del WebACL para la anotación de Ingress"
  value       = aws_wafv2_web_acl.main.arn
}
