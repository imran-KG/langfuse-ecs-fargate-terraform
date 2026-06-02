# Langfuse Terraform — Command Reference

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)
- [Docker](https://www.docker.com/) installed and running

---

## 1. Initial Setup

Copy the example tfvars and fill in your values:

```bash
cp tfvars/example.tfvars tfvars/dev.tfvars
```

Edit `tfvars/dev.tfvars` — minimum required fields:

```hcl
aws_profile   = "your-aws-profile"   # AWS CLI profile name
user          = "your-name"          # Tag for resource identification
allowed_cidrs = ["your-ip/32"]       # Allowed IP — check with: curl https://checkip.amazonaws.com
```

---

## 2. Deploy (Recommended)

Deploy everything with one command:

```bash
./deploy.sh tfvars/dev.tfvars
```

To use a specific AWS profile:

```bash
./deploy.sh tfvars/dev.tfvars my-aws-profile
```

What the script does:
1. Checks prerequisites (terraform, aws, docker)
2. Runs `terraform init`
3. Creates ECR repositories
4. Pushes Langfuse Web, Worker, and ClickHouse images to ECR
5. Deploys all remaining AWS infrastructure
6. Prints the Langfuse URL

> After image push, allow ~2–3 minutes for ECS tasks to start.

---

## 3. Terraform Commands (Manual)

Run from the `infra/` directory:

```bash
cd infra

# Initialize Terraform
terraform init -upgrade

# Preview changes
terraform plan -var-file=../tfvars/dev.tfvars

# Apply all infrastructure
terraform apply -var-file=../tfvars/dev.tfvars

# Destroy all infrastructure
terraform destroy -var-file=../tfvars/dev.tfvars
```

To create only ECR repositories (required before pushing images):

```bash
cd infra
terraform apply \
  -var-file=../tfvars/dev.tfvars \
  -target=module.ecr \
  -auto-approve
```

---

## 4. Manual Image Push

Push images from Docker Hub to ECR (called automatically by `deploy.sh`):

```bash
./infra/modules/ecr/push-images.sh <aws_account_id> <aws_region>
```

With a specific service name and AWS profile:

```bash
./infra/modules/ecr/push-images.sh 123456789012 ap-northeast-1 langfuse my-aws-profile
```

Images pushed (ARM64/Graviton):
- `langfuse/langfuse:3` → ECR `langfuse/web:3`
- `langfuse/langfuse-worker:3` → ECR `langfuse/worker:3`
- `clickhouse/clickhouse-server:24` → ECR `langfuse/clickhouse:24`

---

## 5. Upgrade Langfuse

Update the image tags in your tfvars:

```hcl
langfuse_web_image_tag    = "3.2.0"
langfuse_worker_image_tag = "3.2.0"
```

Redeploy:

```bash
./deploy.sh tfvars/dev.tfvars my-aws-profile
```

---

## 6. Destroy

Delete all AWS infrastructure:

```bash
cd infra
terraform destroy -var-file=../tfvars/dev.tfvars
```

---

## Terraform Outputs

After apply, check these values:

```bash
cd infra
terraform output langfuse_url       # Langfuse access URL
terraform output alb_dns_name       # ALB DNS name
terraform output ecr_web_url        # ECR URL for Langfuse Web
terraform output ecr_worker_url     # ECR URL for Langfuse Worker
terraform output ecr_clickhouse_url # ECR URL for ClickHouse
terraform output rds_endpoint       # RDS PostgreSQL endpoint
terraform output redis_endpoint     # ElastiCache Redis endpoint
terraform output s3_bucket_name     # S3 bucket name
terraform output ecs_cluster_name   # ECS cluster name
```

---

## Key Files

| File | Purpose |
|---|---|
| [deploy.sh](deploy.sh) | Main deploy script (recommended entry point) |
| [infra/modules/ecr/push-images.sh](infra/modules/ecr/push-images.sh) | Push images to ECR |
| [tfvars/example.tfvars](tfvars/example.tfvars) | Configuration template |
| [infra/variables.tf](infra/variables.tf) | All available Terraform variables |
| [infra/backend.tf](infra/backend.tf) | Local state configuration (default) |
