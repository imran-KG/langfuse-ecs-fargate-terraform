output "client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "client_secret_arn" {
  description = "Secrets Manager ARN for Cognito client secret"
  value       = aws_secretsmanager_secret.client_secret.arn
}

output "issuer" {
  description = "Cognito OIDC issuer URL"
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "hosted_ui_url" {
  description = "Cognito hosted UI base URL"
  value       = "https://${var.service_name}.auth.${var.aws_region}.amazoncognito.com"
}
