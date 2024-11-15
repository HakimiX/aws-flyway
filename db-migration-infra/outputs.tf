output "rds_cluster_endpoint" {
  description = "The endpoint of the RDS cluster"
  value       = aws_rds_cluster.serverless.endpoint
}

output "rds_cluster_id" {
  description = "The ID of the RDS cluster"
  value       = aws_rds_cluster.serverless.id
}

output "rds_secret_arn" {
  description = "The ARN of the Secrets Manager secret for RDS credentials"
  value       = aws_secretsmanager_secret.rds_secret.arn
}