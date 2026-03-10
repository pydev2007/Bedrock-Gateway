# Open WebUI with Bedrock

Integrate AWS Bedrock with Open WebUI for AI model testing and development.

## Overview
This project automates the build and run process of [Bedrock Access Gateway](https://github.com/aws-samples/bedrock-access-gateway/tree/main) in AWS.

### Jenkins:
- Builds and pushes the  container to AWS ECR.
- Runs a Docker container to apply Terraform and deploy.
- Cleans up workspace and destroys.
- Runs Terraform destroy when prompted to with a parameter.

### Terraform:
- Creates roles for services (API Gateway, Lambda, etc).
- Builds and deploys services.
- Connects services together.
- Destroys services when prompted to (Excluding S3 and Secrets Manager).

## Architecture
A Jenkins controller runs on a dedicated machine, retrieves secrets from HashiCorp Vault on a seperate machine, and dispatches build jobs to a local agent.

![Graph layout](Diagram.drawio.svg)

## Prerequisites
- A bedrock API key must be generated and put into Secrets Manager. Bedrock Access Gateway utilizes the key for API user authorization.
- User IAM roles for Jenkins and Terraform with permissions for their respective roles.
- IAM user credentials stored in Vault. 
- TFdev Docker image built on agent machine.

## Tools Used
- Jenkins
- Terraform
- Hashicorp Vault
- AWS
    - ECR
    - Secrets Manager
    - Lambda
    - Bedrock
    - API Gateway
    - IAM roles and users
- Docker

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apiGateway"></a> [apiGateway](#module\_apiGateway) | ./modules/apiGateway | n/a |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ./modules/lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_integration.lambda_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.api_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.stage_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_lambda_permission.allow_apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ECR_URI"></a> [ECR\_URI](#input\_ECR\_URI) | URI to the ECR container image. | `string` | n/a | yes |
| <a name="input_KEY_ARN"></a> [KEY\_ARN](#input\_KEY\_ARN) | API key for lambda instance. | `string` | n/a | yes |