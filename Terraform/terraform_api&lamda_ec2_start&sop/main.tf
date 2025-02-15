provider "aws" {
  region = var.region
}

data "aws_availability_zones" "main" {
    state = "available"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}_igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.environment}_rt"
  }
}
resource "aws_route_table_association" "main" {
    route_table_id = aws_route_table.main.id
    subnet_id = aws_subnet.main.id
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.environment}_vpc"
  }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = true
    cidr_block = var.subnet_cidr
    availability_zone = data.aws_availability_zones.main.names[0]
  
    tags = {
      Name = "${var.environment}_subnet"
    }
}

resource "aws_security_group" "main" {
  name = "${var.environment}_sg"
  description = "allow all inbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow all traffic"
  }
}

resource "aws_instance" "main" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.main.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "${var.environment}_instance"
  }
}

resource "aws_iam_role" "main" {
  name = "api_lamda_ec2_stop_start_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
       {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
            Service = "lambda.amazonaws.com"
         }
        },
       ]
    })

  tags = {
    tag-key = "tag-value"
  }
}
resource "aws_iam_policy" "main" {
  name        = "api_lamda_ec2_stop_start_policy"
  description = "Allowing lamda to api, to start & stop ec2 service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = ["ec2:DescribeInstances", "ec2:StartInstances", "ec2:StopInstances", "ec2:Run*"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["apigateway:*"]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "main" {
    role = aws_iam_role.main.name
    policy_arn = aws_iam_policy.main.arn
}

# API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "main" {
  name          = "Ec2ControlApi"
  protocol_type = "HTTP"
}
# API Integration with Lambda
resource "aws_apigatewayv2_integration" "main" {
    api_id = aws_apigatewayv2_api.main.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.main.arn
    payload_format_version = "2.0"
}
# API Route (POST request to trigger Lambda)
resource "aws_apigatewayv2_route" "main" {
  api_id = aws_apigatewayv2_api.main.id
  route_key = "POST /ec2"
  target = "integrations/${aws_apigatewayv2_integration.main.id}"
}
# Deploy the API
resource "aws_apigatewayv2_stage" "main" {
    api_id = aws_apigatewayv2_api.main.id
    name = "dev"
    auto_deploy = true
}


resource "aws_lambda_function" "main" {
  function_name = "StartStopEc2"
  role = aws_iam_role.main.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"
  filename = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout = 50
  environment {
    variables = {
      REGION        = var.region
      AMI_ID        = var.ami
      INSTANCE_TYPE = var.instance_type
      KEY_NAME      = var.key_name
      SUBNET_ID     = aws_subnet.main.id
      INSTANCE_TAG_NAME = "${var.environment}_instance"
    }
  }
}
resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}


