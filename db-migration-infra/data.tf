data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.env}/network_stack/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_a_id" {
  name = "/${var.env}/network_stack/private_subnet_a_id"
}

data "aws_ssm_parameter" "private_subnet_b_id" {
  name = "/${var.env}/network_stack/private_subnet_b_id"
}

data "aws_ssm_parameter" "lambda_security_group_id" {
  name = "/${var.env}/network_stack/lambda_security_group_id"
}

data "aws_ssm_parameter" "rds_security_group_id" {
  name = "/${var.env}/network_stack/rds_security_group_id"
}

data "aws_ssm_parameter" "db_migration_ecr_repo" {
  name = "/${var.env}/network_stack/db_migration_ecr_repo"
}
