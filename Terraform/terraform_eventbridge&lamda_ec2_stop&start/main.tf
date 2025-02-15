provider "aws" {
  region = var.region
}

data "aws_availability_zones" "name" {
  state = "available"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Default.id
  tags = {
    Name = "${var.environment}_IGW"
  }
}

/*
resource "aws_internet_gateway_attachment" "igw" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id = aws_vpc.Default.id
}
*/

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.Default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}_custom"
  }
}

resource "aws_route_table_association" "rt" {
  subnet_id      = aws_subnet.Default.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_vpc" "Default" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}_vpc"
  }
}

resource "aws_subnet" "Default" {
  vpc_id                  = aws_vpc.Default.id
  availability_zone       = data.aws_availability_zones.name.names[0]
  map_public_ip_on_launch = true
  cidr_block              = var.subnet_cidr

  tags = {
    Name = "${var.environment}_subnet"
  }
}

# Creating & Assocoation of EIP for EC2 public ip address 
# Incase if you want ip should not be changed even after instance restart then use EIP
/*
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}_eip"
  }
}
resource "aws_eip_association" "name" {
  instance_id = aws_instance.web.id
  allocation_id = aws_eip.eip.id
} */

# 🔹 EC2 Instance
resource "aws_instance" "web" {
  ami                         = var.ami # ami value fetch from variables
  instance_type               = var.instance_type # instance_type value fetch from variables
  subnet_id                   = aws_subnet.Default.id # subnet id fetch from above subnet resource 
  key_name                    = var.key_name # keypair name fetch from variables
  associate_public_ip_address = true

  tags = {
    Name = "${var.environment}_instance"
  }
}

# 🔹 IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lamda_ec2_start_stop_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 🔹 IAM Policy to allow Lambda to manage EC2
resource "aws_iam_policy" "lambda_ec2_policy" {
  name        = "lambda_ec2_control_policy"
  description = "Allows Lambda to start/stop EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Start*", "ec2:Stop*", "ec2:Describe*", "ec2:Run*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# 🔹 Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

# 🔹 Lambda Function to Start/Stop EC2
resource "aws_lambda_function" "start_stop_ec2" {
  function_name = "StartStopEC2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip" # The ZIP file containing your Python script
  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout = 59

  environment {
    variables = {
      REGION        = var.region
      AMI_ID        = var.ami
      INSTANCE_TYPE = var.instance_type
      KEY_NAME      = var.key_name
      SUBNET_ID     = aws_subnet.Default.id
      INSTANCE_TAG_NAME = "${var.environment}_instance"

    }
  }
}

# 🔹 CloudWatch Event Rule for Scheduling (Start EC2 at 8 AM IST)
resource "aws_cloudwatch_event_rule" "start_ec2" {
  name                = "start-ec2"
  # cronjob ( Minutes Hours DayofMonth Month Dayofweek Year)
  schedule_expression = "cron(30 2 * 2 ? 2025)" #(IST is 5.5 hours ahead of UTC)
  
}

# 🔹 CloudWatch Event Rule for Scheduling (Stop EC2 at 10 PM IST)
resource "aws_cloudwatch_event_rule" "stop_ec2" {
  name                = "stop-ec2"
  schedule_expression = "cron(30 4 * 2 ? 2025)" #(IST is 5.5 hours ahead of UTC)
}

# 🔹 CloudWatch Event Target - Start EC2
resource "aws_cloudwatch_event_target" "start_target" {
  rule = aws_cloudwatch_event_rule.start_ec2.name
  arn  = aws_lambda_function.start_stop_ec2.arn
  input = jsonencode({ "action"= "start", "instance_id"= aws_instance.web.id })
}

# 🔹 CloudWatch Event Target - Stop EC2
resource "aws_cloudwatch_event_target" "stop_target" {
  rule = aws_cloudwatch_event_rule.stop_ec2.name
  arn  = aws_lambda_function.start_stop_ec2.arn
  input = jsonencode({ "action"= "stop", "instance_id"= aws_instance.web.id })
}

# 🔹 Lambda Permissions to Allow CloudWatch Events to Trigger it
resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2.arn
}
