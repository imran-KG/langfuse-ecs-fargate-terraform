variable "service_name" {
  description = "Resource naming prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region for endpoint service names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for endpoint placement"
  type        = list(string)
}
