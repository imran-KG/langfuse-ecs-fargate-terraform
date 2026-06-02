output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "langfuse_url" {
  description = "Langfuse URL via CloudFront"
  value       = var.domain != "" ? "https://${var.domain}" : "https://${aws_cloudfront_distribution.main.domain_name}"
}
