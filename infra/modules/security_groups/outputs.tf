output "web_sg_id" {
  description = "Security group ID for Langfuse Web"
  value       = aws_security_group.web.id
}

output "worker_sg_id" {
  description = "Security group ID for Langfuse Worker"
  value       = aws_security_group.worker.id
}

output "clickhouse_sg_id" {
  description = "Security group ID for ClickHouse"
  value       = aws_security_group.clickhouse.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS PostgreSQL"
  value       = aws_security_group.rds.id
}

output "efs_sg_id" {
  description = "Security group ID for EFS"
  value       = aws_security_group.efs.id
}
