resource "aws_api_gateway_rest_api" "handle_s3_obj" {
  name        = "get-upload-s3-object"
  description = "API Gateway for Hello World Lambda"

}

resource "aws_api_gateway_resource" "s3_object" {
  rest_api_id = aws_api_gateway_rest_api.handle_s3_obj.id
  parent_id   = aws_api_gateway_rest_api.handle_s3_obj.root_resource_id
  path_part   = "s3-object"
}


resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.handle_s3_obj.id
  resource_id   = aws_api_gateway_resource.s3_object.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}

resource "aws_api_gateway_method" "upload_method" {
  rest_api_id   = aws_api_gateway_rest_api.handle_s3_obj.id
  resource_id   = aws_api_gateway_resource.s3_object.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}

resource "aws_api_gateway_method_settings" "default" {
  rest_api_id = aws_api_gateway_rest_api.handle_s3_obj.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
  depends_on = [ aws_api_gateway_account.api_gw_account ]
}


resource "aws_api_gateway_integration" "get_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.handle_s3_obj.id
  resource_id = aws_api_gateway_resource.s3_object.id
  http_method = aws_api_gateway_method.get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}

resource "aws_api_gateway_integration" "upload_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.handle_s3_obj.id
  resource_id = aws_api_gateway_resource.s3_object.id
  http_method = aws_api_gateway_method.upload_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}


resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.production_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.handle_s3_obj.id
  stage_name    = "production"
}

resource "aws_api_gateway_account" "api_gw_account" {
  cloudwatch_role_arn = aws_iam_role.lambda_execution_role.arn
}


resource "aws_api_gateway_deployment" "production_deployment" {
  rest_api_id = aws_api_gateway_rest_api.handle_s3_obj.id

  depends_on = [
    aws_api_gateway_method.get_method,
    aws_api_gateway_integration.get_lambda_integration,
    aws_api_gateway_integration.upload_lambda_integration,
    aws_api_gateway_method.upload_method
  ]
}


resource "aws_api_gateway_authorizer" "cognito_auth" {
  name          = "CognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.handle_s3_obj.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.apigw_user_pool.arn]
}
