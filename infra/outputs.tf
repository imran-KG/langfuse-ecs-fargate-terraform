output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# ECR outputs
output "ecr_web_url" {
  description = "ECR repository URL for Langfuse Web"
  value       = module.ecr.web_url
}

output "ecr_worker_url" {
  description = "ECR repository URL for Langfuse Worker"
  value       = module.ecr.worker_url
}

output "ecr_clickhouse_url" {
  description = "ECR repository URL for ClickHouse"
  value       = module.ecr.clickhouse_url
}

# VPC outputs
output "vpc_id" {
  description = "VPC ID (created or provided)"
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = local.private_subnet_ids
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.langfuse.cluster_name
}

output "langfuse_web_service_name" {
  description = "ECS service name for Langfuse Web (use to get public IP)"
  value       = module.langfuse.web_service_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.langfuse.redis_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.langfuse.s3_bucket_id
}

output "clickhouse_dns" {
  description = "ClickHouse internal DNS name"
  value       = module.clickhouse.dns_name
}

# ALB outputs
output "alb_dns_name" {
  description = "ALB DNS name (when ALB is enabled)"
  value       = module.langfuse.alb_dns_name
}

output "langfuse_url" {
  description = "Langfuse ALB URL (HTTP only — use CloudFront URL for HTTPS)"
  value       = var.enable_alb ? "http://${module.langfuse.alb_dns_name}" : "http://<public-ip>:3000"
}

# CloudFront outputs
output "cloudfront_url" {
  description = "Langfuse URL via CloudFront (custom domain with Basic Auth)"
  value       = module.cloudfront.langfuse_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID (needed to create users)"
  value       = module.cognito.user_pool_id
}

output "cognito_hosted_ui_url" {
  description = "Cognito hosted UI base URL"
  value       = module.cognito.hosted_ui_url
}
