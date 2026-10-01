# 1. IAM policy that allows writing messages to your SQS queue / Política IAM que permite escribir mensajes en tu cola SQS
resource "aws_iam_policy" "saas_app_sqs" {
  name        = "saas-platform-prod-sqs-policy"
  description = "Allows the backend app to publish events to the SQS queue / Permite a la app backend publicar eventos en la cola SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.tenant_events.arn
      }
    ]
  })
}

# 2. IAM (IRSA) role for Kubernetes ServiceAccount / Rol de IAM (IRSA) para la ServiceAccount de Kubernetes
module "saas_app_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "saas-platform-prod-saas-app-irsa"

  role_policy_arns = {
    sqs_policy = aws_iam_policy.saas_app_sqs.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["saas-app:saas-backend-sa"]
    }
  }
}

# 3. Output to copy the ARN of the created role / Output para copiar el ARN del rol creado
output "saas_app_irsa_role_arn" {
  description = "IAM Role ARN for the ServiceAccount / ARN del Rol IAM para la ServiceAccount"
  value       = module.saas_app_irsa.iam_role_arn
}
