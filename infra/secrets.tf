# Random password for RDS
resource "random_password" "db_password" {
  length  = 32
  special = false
}

# Random password for ClickHouse
resource "random_password" "clickhouse_password" {
  length  = 32
  special = false
}

# Random secret for NextAuth
resource "random_password" "nextauth_secret" {
  length  = 64
  special = false
}

# Random salt for API key hashing
resource "random_password" "salt" {
  length  = 32
  special = false
}

# 256-bit encryption key as hex (32 bytes → 64 hex characters)
resource "random_id" "encryption_key" {
  byte_length = 32
}

# Database URL secret
resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${var.service_name}/database-url"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgresql://${module.rds.username}:${random_password.db_password.result}@${module.rds.endpoint}/${var.db_name}"
}

# NextAuth secret
resource "aws_secretsmanager_secret" "nextauth_secret" {
  name                    = "${var.service_name}/nextauth-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "nextauth_secret" {
  secret_id     = aws_secretsmanager_secret.nextauth_secret.id
  secret_string = random_password.nextauth_secret.result
}

# Salt secret
resource "aws_secretsmanager_secret" "salt" {
  name                    = "${var.service_name}/salt"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "salt" {
  secret_id     = aws_secretsmanager_secret.salt.id
  secret_string = random_password.salt.result
}

# Encryption key secret
resource "aws_secretsmanager_secret" "encryption_key" {
  name                    = "${var.service_name}/encryption-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "encryption_key" {
  secret_id     = aws_secretsmanager_secret.encryption_key.id
  secret_string = random_id.encryption_key.hex
}

# ClickHouse password secret
resource "aws_secretsmanager_secret" "clickhouse_password" {
  name                    = "${var.service_name}/clickhouse-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "clickhouse_password" {
  secret_id     = aws_secretsmanager_secret.clickhouse_password.id
  secret_string = random_password.clickhouse_password.result
}
