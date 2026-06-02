variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for Web"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Worker"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID for Web"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group ID for Worker"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "task_role_id" {
  description = "ECS task role ID (for IAM policy attachment)"
  type        = string
}

# Container images
variable "web_image" {
  description = "Langfuse Web container image"
  type        = string
  default     = "langfuse/langfuse:3"
}

variable "worker_image" {
  description = "Langfuse Worker container image"
  type        = string
  default     = "langfuse/langfuse-worker:3"
}

# Resource configuration
variable "web_cpu" {
  description = "Web task CPU"
  type        = number
  default     = 1024
}

variable "web_memory" {
  description = "Web task memory"
  type        = number
  default     = 2048
}

variable "worker_cpu" {
  description = "Worker task CPU"
  type        = number
  default     = 1024
}

variable "worker_memory" {
  description = "Worker task memory"
  type        = number
  default     = 2048
}

variable "worker_desired_count" {
  description = "Worker desired count"
  type        = number
  default     = 1
}

# ElastiCache
variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "nextauth_url" {
  description = "NextAuth URL"
  type        = string
  default     = ""
}

variable "clickhouse_dns_namespace" {
  description = "ClickHouse DNS namespace"
  type        = string
  default     = "langfuse.local"
}

# Secrets
variable "database_url_arn" {
  description = "Database URL secret ARN"
  type        = string
}

variable "nextauth_secret_arn" {
  description = "NextAuth secret ARN"
  type        = string
}

variable "salt_arn" {
  description = "Salt secret ARN"
  type        = string
}

variable "encryption_key_arn" {
  description = "Encryption key secret ARN"
  type        = string
}

variable "clickhouse_password_arn" {
  description = "ClickHouse password secret ARN"
  type        = string
}

variable "email_from_address" {
  description = "From address for Langfuse emails"
  type        = string
  default     = ""
}

variable "auth_disable_signup" {
  description = "Disable new user sign-up (true = only existing users can sign in)"
  type        = bool
  default     = false
}

variable "private_route_table_id" {
  description = "Private route table ID for S3 gateway endpoint"
  type        = string
  default     = null
}

# ALB Configuration
variable "enable_alb" {
  description = "Enable ALB (recommended for production)"
  type        = bool
  default     = true
}

# Custom Domain Configuration
variable "custom_domain" {
  description = "Custom domain for Langfuse (e.g., langfuse.example.com)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for custom domain"
  type        = string
  default     = ""
}




variable "cognito_client_id" {
  description = "Cognito App Client ID"
  type        = string
  default     = ""
}

variable "cognito_issuer" {
  description = "Cognito OIDC issuer URL"
  type        = string
  default     = ""
}

variable "cognito_client_secret_arn" {
  description = "Secrets Manager ARN for Cognito client secret"
  type        = string
  default     = ""
}

variable "auth_disable_username_password" {
  description = "Disable username/password login, force SSO only"
  type        = bool
  default     = false
}
