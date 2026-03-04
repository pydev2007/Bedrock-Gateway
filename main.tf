
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  
}

provider "aws" {
  region = "us-east-1"
}

# Variables referenced in Jenkins file.
variable "KEY_ARN" {
  description = "API key for lambda instance."
  type        = string
}

variable "ECR_URI" {
  description = "URI to the ECR container image."
  type        = string
}

# Modules
module "lambda" {
  source = "./modules/lambda"
  ECR_URI = var.ECR_URI
  SECRET_ARN = var.KEY_ARN
}

module "apiGateway" {
  source = "./modules/apiGateway"
}

# Integrate Lambda function with API Gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = module.apiGateway.api_id
  integration_type = "AWS_PROXY"
  integration_uri  = module.lambda.invoke_arn
}

# Allow API Gateway to execute Lambda function 
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.apiGateway.execution_arn}/*/*"
}

# Add route for API connection
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = module.apiGateway.api_id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage and deploy API for use
resource "aws_apigatewayv2_stage" "stage_api" {
  api_id      = module.apiGateway.api_id
  name        = "api"
  auto_deploy = true
}

