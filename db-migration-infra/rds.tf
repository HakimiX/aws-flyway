resource "aws_rds_cluster" "serverless" {
  cluster_identifier = "rds-serverless-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "serverless"

  # Temporary credentials, real credentials are stored in Secrets Manager
  master_username = "mydbuser"
  master_password = random_password.rds_password.result

  skip_final_snapshot = true

  vpc_security_group_ids = [data.aws_ssm_parameter.rds_security_group_id.value]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  scaling_configuration {
    auto_pause   = false # Disable auto-pause to keep the cluster always available
    max_capacity = 2
    min_capacity = 2
  }

  enable_http_endpoint = true

  depends_on = [aws_secretsmanager_secret_version.rds_secret_version]
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [data.aws_ssm_parameter.private_subnet_a_id.value, data.aws_ssm_parameter.private_subnet_b_id.value]

  tags = {
    Name = "${var.env}-${var.stack_name}-db-subnet-group"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [data.aws_ssm_parameter.private_subnet_a_id.value, data.aws_ssm_parameter.private_subnet_b_id.value]

  tags = {
    Name = "${var.env}-${var.stack_name}-db-subnet-group"
  }
}

# RDS Secret

resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "${var.stack_name}-rds-secret-${random_string.suffix.result}"
  description = "RDS credentials"
  tags = {
    Name = "${var.env}-${var.stack_name}-rds-secret"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = "mydbuser",
    password = random_password.rds_password.result,
  })
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:.,?"

  lifecycle {
    ignore_changes = all
  }
}