variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "langfuse_url" {
  description = "Langfuse public URL (used for OAuth callback and logout)"
  type        = string
}

variable "ses_from_email_address" {
  description = "From address for Cognito emails (must be verified in SES)"
  type        = string
  default     = ""
}

variable "ses_identity_arn" {
  description = "ARN of the SES verified identity for Cognito email sending"
  type        = string
  default     = ""
}
