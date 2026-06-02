terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Service   = var.service_name
      User      = var.user
      ManagedBy = "terraform"
    }
  }
}

# =============================================================================
# Modules
# =============================================================================

module "vpc" {
  count  = local.create_vpc ? 1 : 0
  source = "./modules/vpc"

  service_name   = var.service_name
  vpc_cidr       = var.vpc_cidr
  exclude_az_ids = var.exclude_az_ids
}

module "ecr" {
  source = "./modules/ecr"

  service_name = var.service_name
}

module "security_groups" {
  source = "./modules/security_groups"

  service_name  = var.service_name
  vpc_id        = local.vpc_id
  enable_alb    = var.enable_alb
  allowed_cidrs = var.allowed_cidrs
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  service_name       = var.service_name
  aws_region         = var.aws_region
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids
}

module "iam" {
  source = "./modules/iam"

  service_name                   = var.service_name
  database_url_secret_arn        = aws_secretsmanager_secret.database_url.arn
  nextauth_secret_arn            = aws_secretsmanager_secret.nextauth_secret.arn
  salt_secret_arn                = aws_secretsmanager_secret.salt.arn
  encryption_key_secret_arn      = aws_secretsmanager_secret.encryption_key.arn
  clickhouse_password_secret_arn = aws_secretsmanager_secret.clickhouse_password.arn
  cognito_client_secret_arn      = module.cognito.client_secret_arn
}

module "rds" {
  source = "./modules/rds"

  service_name      = var.service_name
  subnet_ids        = local.private_subnet_ids
  security_group_id = module.security_groups.rds_sg_id
  instance_class    = var.db_instance_class
  db_name           = var.db_name
  db_password       = random_password.db_password.result
  multi_az          = var.db_multi_az
}

module "cognito" {
  source = "./modules/cognito"

  service_name = var.service_name
  aws_region   = var.aws_region
  langfuse_url = var.nextauth_url

  ses_from_email_address = var.email_from_address
  ses_identity_arn       = var.ses_identity_arn
}

module "langfuse" {
  source = "./modules/langfuse"

  service_name             = var.service_name
  aws_region               = var.aws_region
  vpc_id                   = local.vpc_id
  public_subnet_ids        = local.public_subnet_ids
  private_subnet_ids       = local.private_subnet_ids
  web_security_group_id    = module.security_groups.web_sg_id
  worker_security_group_id = module.security_groups.worker_sg_id
  execution_role_arn       = module.iam.task_execution_role_arn
  task_role_arn            = module.iam.task_role_arn
  task_role_id             = module.iam.task_role_id

  web_image            = local.langfuse_web_image
  worker_image         = local.langfuse_worker_image
  web_cpu              = var.web_cpu
  web_memory           = var.web_memory
  worker_cpu           = var.worker_cpu
  worker_memory        = var.worker_memory
  worker_desired_count = var.worker_desired_count
  cache_node_type      = var.cache_node_type

  nextauth_url = var.nextauth_url

  database_url_arn        = aws_secretsmanager_secret.database_url.arn
  nextauth_secret_arn     = aws_secretsmanager_secret.nextauth_secret.arn
  salt_arn                = aws_secretsmanager_secret.salt.arn
  encryption_key_arn      = aws_secretsmanager_secret.encryption_key.arn
  clickhouse_password_arn = aws_secretsmanager_secret.clickhouse_password.arn

  email_from_address             = var.email_from_address
  auth_disable_signup            = var.auth_disable_signup
  auth_disable_username_password = var.auth_disable_username_password
  private_route_table_id         = local.private_route_table_id

  cognito_client_id         = module.cognito.client_id
  cognito_issuer            = module.cognito.issuer
  cognito_client_secret_arn = module.cognito.client_secret_arn

  # ALB configuration
  enable_alb = var.enable_alb

  # Custom domain (optional)
  custom_domain   = var.custom_domain
  route53_zone_id = var.route53_zone_id
}

module "cloudfront" {
  source = "./modules/cloudfront"

  service_name        = var.service_name
  alb_dns_name        = module.langfuse.alb_dns_name
  domain              = var.cloudfront_domain
  certificate_arn     = var.cloudfront_certificate_arn
  route53_zone_id     = var.cloudfront_zone_id
  basic_auth_username = var.basic_auth_username
  basic_auth_password = var.basic_auth_password
}

module "clickhouse" {
  source = "./modules/clickhouse"

  service_name            = var.service_name
  vpc_id                  = local.vpc_id
  private_subnet_ids      = local.private_subnet_ids
  security_group_id       = module.security_groups.clickhouse_sg_id
  efs_security_group_id   = module.security_groups.efs_sg_id
  ecs_cluster_id          = module.langfuse.cluster_id
  execution_role_arn      = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn
  task_role_id            = module.iam.task_role_id
  clickhouse_password_arn = aws_secretsmanager_secret.clickhouse_password.arn
  aws_region              = var.aws_region
  image                   = local.clickhouse_image
  cpu                     = var.clickhouse_cpu
  memory                  = var.clickhouse_memory
}
