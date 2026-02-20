data "aws_iam_policy_document" "bedrock_access" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:InvokeAgent",
      "bedrock:List*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock_access_policy" {
  name        = "bedrock_access_policy"
  policy = data.aws_iam_policy_document.bedrock_access.json
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_bedrock_exec_role"

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

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.bedrock_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



resource "aws_lambda_function" "gateway" {
  function_name = "gateway"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = var.ECR_URI
  environment {
    variables = {
      API_KEY_SECRET_ARN = var.SECRET_ARN
    }
    }

  memory_size = 512
  timeout     = 30
}