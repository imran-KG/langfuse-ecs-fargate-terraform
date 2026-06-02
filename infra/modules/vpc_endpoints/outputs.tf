output "ecr_api_endpoint_id" {
  description = "VPC endpoint ID for ECR API"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "VPC endpoint ID for ECR Docker Registry"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_endpoint_id" {
  description = "VPC endpoint ID for CloudWatch Logs"
  value       = aws_vpc_endpoint.logs.id
}

output "secretsmanager_endpoint_id" {
  description = "VPC endpoint ID for Secrets Manager"
  value       = aws_vpc_endpoint.secretsmanager.id
}
