# 1. Create the main SQS queue for Tenants events / Crear la cola principal de SQS para eventos de Tenants
resource "aws_sqs_queue" "tenant_events" {
  name                      = "${var.project_name}-${var.environment}-tenant-events"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB
  message_retention_seconds = 86400  # Retain messages for 1 day (24 hours) / Guardar mensajes durante 1 día (24 horas)
  receive_wait_time_seconds = 10     # Long polling to reduce API costs / Long polling para reducir costes de API

  # Uses AWS SQS-managed encryption (SSE-SQS) at zero extra cost
  sqs_managed_sse_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-tenant-events-queue"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
# 2. Output to easily obtain the queue URL / Output para obtener la URL de la cola fácilmente
output "sqs_queue_url" {
  description = "SQS queue URL for tenant events"
  value       = aws_sqs_queue.tenant_events.id
}
output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.tenant_events.arn
}
