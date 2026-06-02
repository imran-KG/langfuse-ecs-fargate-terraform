resource "aws_cognito_user_pool" "main" {
  name                     = var.service_name
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  dynamic "email_configuration" {
    for_each = var.ses_identity_arn != "" ? [1] : []
    content {
      email_sending_account = "DEVELOPER"
      from_email_address    = var.ses_from_email_address
      source_arn            = var.ses_identity_arn
    }
  }

  tags = {
    Name = var.service_name
  }
}

# Cognito hosted UI domain (must be globally unique)
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.service_name
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.service_name}-langfuse"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = ["${var.langfuse_url}/api/auth/callback/cognito"]
  logout_urls                          = [var.langfuse_url]
  supported_identity_providers         = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_secretsmanager_secret" "client_secret" {
  name                    = "${var.service_name}/cognito-client-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "client_secret" {
  secret_id     = aws_secretsmanager_secret.client_secret.id
  secret_string = aws_cognito_user_pool_client.main.client_secret
}
