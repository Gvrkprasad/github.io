data "aws_s3_bucket" "bucket_1" {
    bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "bucket_1" {
  bucket = data.aws_s3_bucket.bucket_1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_1" {
  bucket = data.aws_s3_bucket.bucket_1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_1" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_1,
    aws_s3_bucket_public_access_block.bucket_1,
  ]

  bucket = data.aws_s3_bucket.bucket_1.id
  acl    = "public-read"
}

resource "aws_sns_topic" "sns_lamda" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "sns_lamda" {
  topic_arn = aws_sns_topic.sns_lamda.arn
  protocol  = "email-json"          #sms,lamda deliver options
  endpoint  = "glpsk370@gmail.com"
}

resource "aws_iam_role" "lambda_role" {
  name = "s3-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "s3-object-notification"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function_payload1.zip"
}

resource "aws_lambda_permission" "s3_invocation_permission" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.bucket_1.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_object" "object" {
  bucket = data.aws_s3_bucket.bucket_1.bucket
  key    = "SG.png"
  source = var.file_path
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  content_type = "text/html"
  acl = "public-read"
}