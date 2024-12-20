resource "aws_cognito_user_pool" "apigw_user_pool" {
  name = "apigw_user_pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
  }

  username_attributes = ["email"]
}


resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "apigw_client"
  user_pool_id = aws_cognito_user_pool.apigw_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  generate_secret = false
}

resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.apigw_user_pool.id
  username     = "testuser@example.com"
  attributes = {
    email = "testuser@example.com"
  }

  password = "TempPassword123!"
  force_alias_creation = false
  message_action = "SUPPRESS"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${data.aws_caller_identity.current.account_id}-apigw"
  user_pool_id = aws_cognito_user_pool.apigw_user_pool.id
}
