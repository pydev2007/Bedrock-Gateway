output "api_id" {
  value = aws_apigatewayv2_api.gateway-api.id
  description = "Base API ID"
}

output "execution_arn" {
  value = aws_apigatewayv2_api.gateway-api.execution_arn
  description = "Execution ARN for permissions to run Lambda"
}
