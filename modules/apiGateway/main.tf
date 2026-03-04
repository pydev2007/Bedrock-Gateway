# Initialize API creation
resource "aws_apigatewayv2_api" "gateway-api" {
  name          = "gateway-api"
  protocol_type = "HTTP"
}