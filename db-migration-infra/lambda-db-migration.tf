resource "aws_lambda_function" "db_init_lambda" {
  function_name = "db-init-lambda"
  role          = aws_iam_role.db_init_lambda_exec_role.arn
  architectures = ["arm64"] # might need to be updated to "x86_64"
  package_type  = "Image"
  image_uri     = "${data.aws_ssm_parameter.db_migration_ecr_repo.value}:latest"
  timeout       = var.lambda.timeout
  memory_size   = var.lambda.memory_size

  vpc_config {
    subnet_ids         = [data.aws_ssm_parameter.private_subnet_a_id.value, data.aws_ssm_parameter.private_subnet_b_id.value]
    security_group_ids = [data.aws_ssm_parameter.lambda_security_group_id.value]
  }

  environment {
    variables = {
      DB_SECRET_ARN              = aws_secretsmanager_secret.rds_secret.arn
      DB_ENDPOINT                = aws_rds_cluster.serverless.endpoint
      DB_NAME                    = "postgres"
      DB_MIGRATION_BUCKET        = aws_s3_bucket.db_migration_bucket.bucket
      DB_MIGRATION_BUCKET_PREFIX = "migrations"
    }
  }

  tags = {
    Name = "${var.env}-${var.stack_name}"
  }

  depends_on = [
    aws_iam_role.db_init_lambda_exec_role,
    aws_iam_role_policy.db_init_lambda_exec_policy,
    aws_rds_cluster.serverless,
    aws_s3_object.migration_files
  ]
}

resource "aws_iam_role" "db_init_lambda_exec_role" {
  name = "db-init-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "db_init_lambda_basic_execution" {
  role       = aws_iam_role.db_init_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "db_init_lambda_exec_policy" {
  role = aws_iam_role.db_init_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:*",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.db_migration_bucket.arn}",
          "${aws_s3_bucket.db_migration_bucket.arn}/*",
          aws_secretsmanager_secret.rds_secret.arn
        ],
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ],
  })
}
