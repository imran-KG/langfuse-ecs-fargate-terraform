variable "service_name" {
  description = "Resource naming prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group placement"
  type        = string
}

variable "enable_alb" {
  description = "Whether ALB is enabled; controls web SG direct-access ingress rule"
  type        = bool
  default     = true
}

variable "allowed_cidrs" {
  description = "Allowed CIDR blocks for direct web access (used when enable_alb = false)"
  type        = list(string)
}
