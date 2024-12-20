resource "aws_api_gateway_rest_api" "hello_world" {
  name        = "basic-invoke-lambda-function"
  description = "API Gateway for Hello World Lambda"

}


resource "aws_api_gateway_resource" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  parent_id   = aws_api_gateway_rest_api.hello_world.root_resource_id
  path_part   = "hello-world"

}


resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  resource_id   = aws_api_gateway_resource.hello_world.id
  http_method   = "GET"
  authorization = "NONE"
  
}


resource "aws_api_gateway_method_settings" "default" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    
  }
}


resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  resource_id = aws_api_gateway_resource.hello_world.id
  http_method = aws_api_gateway_method.hello_world_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.hello_world_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  stage_name    = "production"
}

resource "aws_api_gateway_account" "api_gw_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}


resource "aws_api_gateway_deployment" "hello_world_deployment" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id

  depends_on = [
    aws_api_gateway_method.hello_world_method,
    aws_api_gateway_integration.lambda_integration
  ]
}
