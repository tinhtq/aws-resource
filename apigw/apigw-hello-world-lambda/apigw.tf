resource "aws_api_gateway_rest_api" "hello_world" {
  name        = "basic-invoke-lambda-function"
  description = "API Gateway for Hello World Lambda"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  parent_id   = aws_api_gateway_rest_api.hello_world.root_resource_id
  path_part   = "{proxy+}"
}
