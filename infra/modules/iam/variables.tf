variable "service_name" {
  description = "Resource naming prefix"
  type        = string
}

variable "database_url_secret_arn" {
  description = "ARN of the database URL Secrets Manager secret"
  type        = string
}

variable "nextauth_secret_arn" {
  description = "ARN of the NextAuth secret"
  type        = string
}

variable "salt_secret_arn" {
  description = "ARN of the salt secret"
  type        = string
}

variable "encryption_key_secret_arn" {
  description = "ARN of the encryption key secret"
  type        = string
}

variable "clickhouse_password_secret_arn" {
  description = "ARN of the ClickHouse password secret"
  type        = string
}

variable "cognito_client_secret_arn" {
  description = "ARN of the Cognito client secret"
  type        = string
}
