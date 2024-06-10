# Specify the provider and access details
provider "aws" {
  region                  = var.region
  shared_credentials_files= [var.path_file_credentials]
  profile                 = var.profile_name
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
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
      }
    ]
  })
  tags = {
    Username = "victor.shvartsman"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_lambda" {
  filename         = "app.zip"
  function_name    = "app"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler"
  source_code_hash = filebase64sha256("app.zip")
  runtime          = "python3.8"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}
resource "aws_api_gateway_rest_api" "api" {
  name        = "MyAPIGateway"
  description = "API Gateway for Lambda"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{user}"
}

resource "aws_api_gateway_resource" "sub_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.resource.id
  path_part   = "{repo}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.sub_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.sub_resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

output "api_endpoint" {
  value = "curl ${aws_api_gateway_deployment.deployment.invoke_url}/nginx/agent"
}
