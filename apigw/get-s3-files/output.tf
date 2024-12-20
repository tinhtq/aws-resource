output "api_upload_object" {
  value = aws_api_gateway_stage.production.invoke_url
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "domain_pool_id" {
  value = aws_cognito_user_pool_domain.main.id
}

output "auth_url" {
  value =  "https://${aws_cognito_user_pool_domain.main.id}.auth.us-east-1.amazoncognito.com/oauth2/authorize"
}

output "access_token_url" {
    value =  "https://${aws_cognito_user_pool_domain.main.id}.auth.us-east-1.amazoncognito.com/oauth2/token"
}