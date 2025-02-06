resource "aws_iam_policy" "iam" {
  name        = "${var.environment}_policy"
  description = "IAM policy for Lambda to access SNS, RDS, and API Gateway"
 
 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "*"
        ]
        Resource = var.rds_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = var.s3_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke",
          "*"
        ]
        Resource = "arn:aws:sns:ap-south-1:816069156122:playandfit"
      }
    ]
  })
}


resource "aws_iam_role" "iam" {
  name = "${var.environment}_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.environment}_role"
  }
}


resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.iam.name
  policy_arn = aws_iam_policy.iam.arn
}

resource "aws_iam_role" "rds" {
  name = "${var.environment}_rdsrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.environment}_rdsrole"
  }
}
  


resource "aws_s3_bucket_policy" "public_read" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::playandfit/*"
    }
  ]
})
}
