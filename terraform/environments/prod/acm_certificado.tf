# 1. We generate a 2048-bit RSA private cryptographic key pair / Generamos un par de llaves criptográficas privadas RSA de 2048 bits
resource "tls_private_key" "argocd_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. We generate the self-signed SSL certificate using those keys / Fabricamos el certificado SSL firmado por nosotros mismos con esas llaves
resource "tls_self_signed_cert" "argocd_cert" {
  private_key_pem = tls_private_key.argocd_key.private_key_pem

  subject {
    common_name  = "argocd.saas-platform.local"
    organization = "SaaS Platform Prod"
  }

  validity_period_hours = 8760 # Valid for 1 year / Válido por 1 año

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth", # ndicates that it will be used to authenticate an HTTPS server / Indica que servirá para autenticar un servidor HTTPS
  ]
}

# 3. We uploaded the keys and the certificate to AWS ACM (Certificate Manager) / Subimos las llaves y el certificado a AWS ACM (Certificate Manager)
resource "aws_acm_certificate" "argocd_acm" {
  private_key      = tls_private_key.argocd_key.private_key_pem
  certificate_body = tls_self_signed_cert.argocd_cert.cert_pem

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
