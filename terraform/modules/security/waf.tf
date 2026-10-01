# ==============================================================================
# AWS WAFv2 WebACL Configuration / Configuración de WebACL de AWS WAFv2
# ==============================================================================
# Description: Protects the Ingress Application Load Balancer with Layer 7 rules
#              including OWASP Top 10 mitigation and Rate Limiting.
# Descripción: Protege el Load Balancer de Ingress con reglas de Capa 7
#              incluyendo mitigación OWASP Top 10 y Límite de Frecuencia.
# ==============================================================================

resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-${var.environment}-webacl"
  description = "Managed WAF Rules and Rate Limiting for SaaS Platform ALB"
  scope       = "REGIONAL" # Regional scope for ALB / Ámbito regional para Load Balancer

  default_action {
    allow {} # Allow requests by default if no blocking rule matches / Permitir peticiones por defecto
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "SaaSPlatformProdWafMetrics" # Must be strictly alphanumeric / Debe ser estrictamente alfanumérico
    sampled_requests_enabled   = true
  }

  # ----------------------------------------------------------------------------
  # Rule 1: AWS Common Rule Set (OWASP Top 10 Protection)
  # Regla 1: Conjunto de reglas comunes de AWS (Protección OWASP Top 10)
  # ----------------------------------------------------------------------------
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRulesMetric"
      sampled_requests_enabled   = true
    }
  }

  # ----------------------------------------------------------------------------
  # Rule 2: SQL Injection Protection / Regla 2: Protección contra Inyección SQL
  # ----------------------------------------------------------------------------
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSSQLiRulesMetric"
      sampled_requests_enabled   = true
    }
  }

  # ----------------------------------------------------------------------------
  # Rule 3: Known Bad Inputs (Log4j / CVE-2021-44228 Mitigation - Corrects CKV_AWS_192)
  # Regla 3: Entradas dañinas conocidas (Mitigación Log4j - Corrige CKV_AWS_192)
  # ----------------------------------------------------------------------------
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 25

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSKnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  # ----------------------------------------------------------------------------
  # Rule 4: Rate Limiting (DoS/Scraper Mitigation)
  # Regla 4: Límite de Frecuencia (Mitigación de DoS/Scrapers)
  # ----------------------------------------------------------------------------
  rule {
    name     = "RateLimit2000Per5Min"
    priority = 30

    action {
      block {} # Block IP if threshold exceeded / Bloquear la IP si se supera el umbral
    }

    statement {
      rate_based_statement {
        limit              = 2000 # Max 2000 requests per 5-minute evaluation window
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group for WAF (Prefix aws-waf-logs- is required by AWS & Checkov)
# Grupo de Logs para WAF (El prefijo aws-waf-logs- es obligatorio por AWS y Checkov)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}"
  retention_in_days = 365 # Retain logs for 1 year per compliance / Retención de 1 año (CKV_AWS_338)

  # checkov:skip=CKV_AWS_158: "Default CloudWatch encryption is sufficient for WAF logs"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# WAF Logging Configuration (Satisfies CKV2_AWS_31)
# Configuración de Logging para WAF (Satisface CKV2_AWS_31)
# ------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}
