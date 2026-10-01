# ==============================================================================
# VPC Flow Logs & CloudWatch Configuration / Configuración de VPC Flow Logs
# ==============================================================================
# Description: Captures IP traffic passing through VPC ENIs and sends to CloudWatch
# Descripción: Captura el tráfico IP de las ENIs de la VPC y lo envía a CloudWatch
# ==============================================================================

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.project_name}-${var.environment}"
  retention_in_days = 365 # Retain logs for 365 days / Retener registros durante 365 días
  # checkov:skip=CKV_AWS_158: "AWS managed SSE is sufficient for demo/dev VPC flow log groups"
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"      # Capture ALL traffic (ACCEPT & REJECT) / Capturar TODO el tráfico
  vpc_id          = var.vpc_id # Reference passed from main environment / Referencia pasada desde el entorno principal

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-log"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
