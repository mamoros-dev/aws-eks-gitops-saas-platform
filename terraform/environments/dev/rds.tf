# ==============================================================================
# Environment / Entorno: terraform/environments/dev/rds.tf
# Description: Managed Amazon RDS PostgreSQL & AWS Secrets Manager setup
# Descripción: Base de datos PostgreSQL gestionada y Secrets Manager
# ==============================================================================

# 1. Random database password / Contraseña aleatoria para la Base de Datos
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. RDS Subnet Group (places the database in private subnets) / Subnet Group de RDS (ubica la BD en subredes privadas)
resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 3. Security Group for the RDS instance / Security Group para la Instancia RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security Group for RDS PostgreSQL database"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rule: Allows only port 5432 from the EKS nodes' Security Group / Regla de Entrada: Solo permite el puerto 5432 desde el Security Group de los nodos de EKS
  ingress {
    description     = "PostgreSQL access from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [module.eks.cluster_security_group_id]
  }

  # Egress Rule: Open outbound access for responses / Regla de Salida: Salida abierta para respuestas
  egress {
    description = "Allow all outbound traffic / Permitir todo el trafico de salida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 4. Amazon RDS PostgreSQL instance / Instancia de Amazon RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier            = "${var.project_name}-${var.environment}-db"
  allocated_storage     = 20 # 20 GB initial storage / 20 GB de almacenamiento inicial
  max_allocated_storage = 50 # Disk auto-scaling up to 50 GB / Autoescalado de disco hasta 50 GB
  engine                = "postgres"
  engine_version        = "15"           # Stable version of PostgreSQL / Versión Estable de PostgreSQL
  instance_class        = "db.t4g.micro" # Cost-effective instance ideal for dev (ARM Graviton) / Instancia económica ideal para dev (ARM Graviton)

  db_name  = "appdb"   # Initial database name / Nombre inicial de la BD
  username = "dbadmin" # Admin user / Usuario administrador
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false # INACCESSIBLE from the Internet / INACCESIBLE desde Internet
  skip_final_snapshot = true  # In dev, we skip the final snapshot upon destruction / En dev omitimos el snapshot final al destruir

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 5. AWS Secrets Manager: Securely store credentials in AWS / AWS Secrets Manager: Guardar las credenciales de forma segura en AWS
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-${var.environment}-db-credentials-v1"
  recovery_window_in_days = 0 # Allows immediate deletion in dev if we run `destroy`/Permite borrado inmediato en dev si hacemos destroy

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-credentials"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 6. Store JSON data in the secret / Guardar los datos JSON en el Secreto
resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = aws_db_instance.postgres.db_name
    username = aws_db_instance.postgres.username
    password = random_password.db_password.result
  })
}
