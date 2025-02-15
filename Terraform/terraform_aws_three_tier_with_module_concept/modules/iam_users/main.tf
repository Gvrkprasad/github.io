# Generate a random password
resource "random_password" "iam_user_password" {
  length           = 8             # Set the desired password length
  special          = true            # Include special characters
  upper            = true            # Include uppercase letters
  lower            = true            # Include lowercase letters
  numeric          = true            # Include numbers
  override_special = "@"          # Customize allowed special characters
}

# Create the IAM User
resource "aws_iam_user" "user1" {
    name = var.iam_user1

    tags = {
        Name = "${var.environment}-user"
        Environment = var.environment
    }
}

# Create a Login Profile for the User (Set Custom Password)
resource "aws_iam_user_login_profile" "login_profile" {
  user = aws_iam_user.user1.name
  password_reset_required = true   #Enforce password reset on first login
}

# Create a Customer-Managed Policy for S3 Bucket Access
resource "aws_iam_policy" "s3_bucket_access_policy" {
  name        = "${var.environment}-bucket-policy"
  description = "Policy for accessing S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.env_bucket_name}",             # Bucket-level access
          "arn:aws:s3:::${var.env_bucket_name}/*"            # Object-level access
        ]
      }
    ]
  })
}

# Attach the Policy to the IAM User
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.user1.name
  policy_arn = aws_iam_policy.s3_bucket_access_policy.arn
}