output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "task_role_id" {
  description = "ID of the ECS task role (used for inline policy attachment by child modules)"
  value       = aws_iam_role.ecs_task.id
}
