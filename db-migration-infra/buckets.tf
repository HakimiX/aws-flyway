resource "aws_s3_bucket" "db_migration_bucket" {
  bucket = "${var.stack_name}-db-migration-bucket-${random_id.s3_bucket_id.hex}"

  tags = {
    Name = "${var.stack_name}-db-migration-bucket"
  }
}

resource "random_id" "s3_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket_ownership_controls" "db_migration_bucket_ownership" {
  bucket = aws_s3_bucket.db_migration_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket_public_access_block.db_migration_bucket_block]
}

resource "aws_s3_bucket_public_access_block" "db_migration_bucket_block" {
  bucket = aws_s3_bucket.db_migration_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "db_migration_bucket_policy" {
  bucket = aws_s3_bucket.db_migration_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLambdaAccess",
        Effect = "Allow",
        Principal = {
          "AWS" : "${aws_iam_role.db_init_lambda_exec_role.arn}"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.db_migration_bucket.arn}",
          "${aws_s3_bucket.db_migration_bucket.arn}/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.db_migration_bucket_block]
}

# Upload db migration files
resource "aws_s3_object" "migration_files" {
  for_each = fileset("${path.module}/../db-migration-lambda/db/migrations", "*")

  bucket = aws_s3_bucket.db_migration_bucket.bucket
  key    = "migrations/${each.value}"
  source = "${path.module}/../db-migration-lambda/db/migrations/${each.value}"
  etag   = filemd5("${path.module}/../db-migration-lambda/db/migrations/${each.value}")

  depends_on = [aws_s3_bucket.db_migration_bucket]
}
