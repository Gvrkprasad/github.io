provider "aws" {
  region = "ap-south-1"
}

# DynamoDB Table
resource "aws_dynamodb_table" "booking_table" {
  name           = "booking_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "phone_number"
  range_key      = "booking_date"

  attribute {
    name = "phone_number"
    type = "S"
  }

  attribute {
    name = "booking_date"
    type = "S"
  }
}

# SNS Topic for SMS Notifications
resource "aws_sns_topic" "booking_topic" {
  name = "booking_notifications"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.booking_topic.arn
  protocol  = "email-json"
  endpoint  = "glpsk370@gmail.com"
}
# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

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

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem"]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.booking_table.arn
      },
      {
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = aws_sns_topic.booking_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "save_booking_lambda" {
  filename         = "lamda_function.zip"
  function_name    = "save_booking_function"
  handler          = "lamda_function.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 59

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.booking_table.name
      SNS_TOPIC    = aws_sns_topic.booking_topic.arn
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "booking_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.save_booking_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /book"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

