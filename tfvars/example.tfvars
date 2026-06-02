# AWS Configuration
aws_region   = "ap-northeast-1"
aws_profile  = "your-aws-profile"
service_name = "langfuse"

# Resource Tags (for easy identification in AWS Console)
user = "your-name" # e.g., "alice", "team-ml"

# Container Image Tags — update these to upgrade versions
langfuse_web_image_tag    = "3"
langfuse_worker_image_tag = "3"
clickhouse_image_tag      = "24"

# Network Configuration (auto-create VPC)
vpc_cidr = "10.0.0.0/16"

# Option B: Use existing VPC (uncomment and set values)
# vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
# public_subnet_ids  = ["subnet-xxxxxxxxxxxxxxxxx"]
# private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]

# Access Control — your IP only
# Check your IP: curl https://checkip.amazonaws.com
allowed_cidrs = ["203.0.113.1/32"]

# RDS Configuration
db_instance_class = "db.t4g.micro"
db_name           = "langfuse"
db_multi_az       = false

# ElastiCache Configuration
cache_node_type = "cache.t4g.micro"

# ECS - Web Configuration
web_cpu    = 1024 # 1 vCPU
web_memory = 2048 # 2 GB

# ECS - Worker Configuration
worker_desired_count = 1
worker_cpu           = 1024 # 1 vCPU
worker_memory        = 2048 # 2 GB

# ECS - ClickHouse Configuration
clickhouse_cpu    = 2048 # 2 vCPU
clickhouse_memory = 4096 # 4 GB

# Langfuse Configuration
auth_disable_signup            = false
auth_disable_username_password = false

# Custom domain (optional)
# nextauth_url       = "https://langfuse.example.com"
# email_from_address = "noreply@example.com"

# SES (required for Cognito invitation emails)
# ses_identity_arn = "arn:aws:ses:ap-northeast-1:123456789012:identity/example.com"

# CloudFront Configuration (optional)
# Adds CloudFront in front of ALB with HTTP Basic Auth protection.
# ACM certificate must be in us-east-1 (CloudFront requirement).
# cloudfront_domain          = "langfuse.example.com"
# cloudfront_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# cloudfront_zone_id         = "Z1234567890ABC"
# basic_auth_username        = "admin"
# basic_auth_password        = "your-secure-password"
