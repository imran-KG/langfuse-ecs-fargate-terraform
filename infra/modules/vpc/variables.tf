variable "service_name" {
  description = "Resource naming prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "exclude_az_ids" {
  description = "AZ IDs to exclude (e.g., use1-az3 doesn't support ARM64 Fargate in us-east-1)"
  type        = list(string)
  default     = ["use1-az3"]
}
