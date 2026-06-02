variable "service_name" {
  description = "Resource naming prefix"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used as CloudFront origin"
  type        = string
}

variable "domain" {
  description = "Custom domain for CloudFront (e.g., langfuse.example.com). Leave empty to use the default *.cloudfront.net domain."
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront HTTPS. Required when domain is set."
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the CloudFront domain"
  type        = string
  default     = ""
}

variable "basic_auth_username" {
  description = "HTTP Basic Auth username"
  type        = string
}

variable "basic_auth_password" {
  description = "HTTP Basic Auth password"
  type        = string
  sensitive   = true
}
