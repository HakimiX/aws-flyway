resource "aws_ssm_parameter" "rds_cluster_endpoint" {
  name  = "/${var.env}/${var.stack_name}/rds_cluster_endpoint"
  type  = "String"
  value = aws_rds_cluster.serverless.endpoint
}

resource "aws_ssm_parameter" "rds_cluster_id" {
  name  = "/${var.env}/${var.stack_name}/rds_cluster_id"
  type  = "String"
  value = aws_rds_cluster.serverless.id
}

resource "aws_ssm_parameter" "rds_secret_arn" {
  name  = "/${var.env}/${var.stack_name}/rds_secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.rds_secret.arn
}