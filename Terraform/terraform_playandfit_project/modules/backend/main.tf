resource "aws_lambda_function" "frontend" {
  filename = var.lambda_filename
  function_name = var.lambda_function_name
  role = var.iam_lambda_rds_role_arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  source_code_hash = filebase64sha256("${path.root}/${var.lambda_filename}")
  architectures   = ["x86_64"]

  

  environment {
    variables = {
        DATABASE_URL   = var.database_url
        DB_USERNAME    = var.db_username
        DB_PASSWORD    = var.db_password
        SNS_TOPIC      = var.sns_topic_arn
        DB_NAME        = var.db_name
      }
    }
  }

  resource "aws_lambda_permission" "lambda_permission" {
  
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.frontend.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_apigatewayv2_api.api_http.execution_arn}/*"
}

resource "aws_lambda_function_event_invoke_config" "destination" {
  function_name = aws_lambda_function.frontend.function_name

  destination_config {
    on_failure {
      destination = var.sns_topic_arn
    }

    on_success {
      destination = var.sns_topic_arn
    }
  }
}

# API Gateway Information & Integration
resource "aws_apigatewayv2_api" "api_http" {
    name          = "playandfit_api"
    protocol_type = "HTTP"

    cors_configuration {
    allow_origins = ["http://playandfit.s3-website.ap-south-1.amazonaws.com"]  # Allow requests from any origin
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    expose_headers = ["Content-Type"]
    max_age = 300
  }
}
  
resource "aws_apigatewayv2_stage" "api_stage" {
    api_id = aws_apigatewayv2_api.api_http.id
    name   = "dev"
    auto_deploy = true
    }
resource "aws_apigatewayv2_integration" "api_integration" {
    api_id             = aws_apigatewayv2_api.api_http.id
    integration_type   = "AWS_PROXY"
    integration_uri    = aws_lambda_function.frontend.arn
    payload_format_version = "2.0"
  }
resource "aws_apigatewayv2_route" "post_route" {
    api_id             = aws_apigatewayv2_api.api_http.id
    route_key = "POST /book"
    target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  }  

resource "aws_apigatewayv2_route" "get_route" {
    api_id             = aws_apigatewayv2_api.api_http.id
    route_key = "GET /book"
    target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  }  
resource "aws_apigatewayv2_route" "options_route" {
    api_id             = aws_apigatewayv2_api.api_http.id
    route_key = "OPTIONS /book"
    target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  }    

