output "web_url" {
  description = "ECR repository URL for Langfuse Web"
  value       = aws_ecr_repository.web.repository_url
}

output "worker_url" {
  description = "ECR repository URL for Langfuse Worker"
  value       = aws_ecr_repository.worker.repository_url
}

output "clickhouse_url" {
  description = "ECR repository URL for ClickHouse"
  value       = aws_ecr_repository.clickhouse.repository_url
}
