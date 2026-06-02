#!/bin/bash
# =============================================================================
# One-command Langfuse deployment
# =============================================================================
# Usage:
#   ./deploy.sh <tfvars_file> [aws_profile]
#
# Examples:
#   ./deploy.sh tfvars/dev.tfvars
#   ./deploy.sh tfvars/dev.tfvars my-aws-profile
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TFVARS_FILE="${1:-tfvars/dev.tfvars}"
AWS_PROFILE="${2:-}"

# Clear any env-level credentials so AWS_PROFILE takes full effect
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

step() { echo -e "\n${BLUE}==>[${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }

if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE
fi

# =============================================================================
# Preflight checks
# =============================================================================
step "Checking prerequisites..."

command -v terraform &>/dev/null || fail "terraform not installed"
command -v aws       &>/dev/null || fail "aws CLI not installed"
command -v docker    &>/dev/null || fail "docker not installed"
docker info &>/dev/null          || fail "docker is not running"

[ -f "$TFVARS_FILE" ] || fail "tfvars file not found: $TFVARS_FILE"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null) \
  || fail "AWS credentials not configured — run: aws configure"

PROFILE_MSG="${AWS_PROFILE:-default}"
ok "Prerequisites OK (account: ${AWS_ACCOUNT_ID}, profile: ${PROFILE_MSG})"
# Note: AWS_ACCOUNT_ID above is used only for preflight. The real account ID
# is extracted from the ECR URL after terraform creates the repos (see Step 3).

# =============================================================================
# Step 1 — Terraform init
# =============================================================================
step "Step 1/4 — Terraform init..."
cd infra
terraform init -upgrade -input=false

# =============================================================================
# Step 2 — Create ECR repositories first
# =============================================================================
step "Step 2/4 — Creating ECR repositories..."
terraform apply \
  -var-file="../${TFVARS_FILE}" \
  -target=module.ecr \
  -input=false

ok "ECR repositories created"

AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || \
  grep 'aws_region' "../${TFVARS_FILE}" | awk -F'"' '{print $2}' | head -1)
[ -z "$AWS_REGION" ] && AWS_REGION="ap-northeast-1"

SERVICE_NAME=$(grep 'service_name' "../${TFVARS_FILE}" | awk -F'"' '{print $2}' | head -1)
[ -z "$SERVICE_NAME" ] && SERVICE_NAME="langfuse"

# Extract the real account ID from the ECR URL Terraform just created
ECR_WEB_URL=$(terraform output -raw ecr_web_url 2>/dev/null || echo "")
if [ -n "$ECR_WEB_URL" ]; then
  AWS_ACCOUNT_ID=$(echo "$ECR_WEB_URL" | cut -d'.' -f1)
  ok "Using account ID from ECR: ${AWS_ACCOUNT_ID}"
fi

cd ..

# Read image tags from tfvars to pass to push-images.sh
LANGFUSE_IMAGE_TAG=$(grep '^langfuse_web_image_tag' "${TFVARS_FILE}" | awk -F'"' '{print $2}' | head -1)
LANGFUSE_WORKER_IMAGE_TAG=$(grep '^langfuse_worker_image_tag' "${TFVARS_FILE}" | awk -F'"' '{print $2}' | head -1)
CLICKHOUSE_IMAGE_TAG=$(grep '^clickhouse_image_tag' "${TFVARS_FILE}" | awk -F'"' '{print $2}' | head -1)
[ -z "$LANGFUSE_IMAGE_TAG" ]        && LANGFUSE_IMAGE_TAG="3"
[ -z "$LANGFUSE_WORKER_IMAGE_TAG" ] && LANGFUSE_WORKER_IMAGE_TAG="3"
[ -z "$CLICKHOUSE_IMAGE_TAG" ]      && CLICKHOUSE_IMAGE_TAG="24"

# =============================================================================
# Step 3 — Push images to ECR
# =============================================================================
step "Step 3/4 — Pushing images to ECR..."
ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
docker logout "${ECR_BASE}" &>/dev/null || true
aws ecr get-login-password --region "${AWS_REGION}" --profile "${AWS_PROFILE}" \
  | docker login --username AWS --password-stdin "${ECR_BASE}" \
  || fail "ECR login failed"
ok "ECR login successful"
./infra/modules/ecr/push-images.sh "${AWS_ACCOUNT_ID}" "${AWS_REGION}" "${SERVICE_NAME}" "${AWS_PROFILE}" "${LANGFUSE_IMAGE_TAG}" "${CLICKHOUSE_IMAGE_TAG}" "${LANGFUSE_WORKER_IMAGE_TAG}"
ok "All images pushed to ECR"

# =============================================================================
# Step 4 — Deploy remaining infrastructure
# =============================================================================
step "Step 4/4 — Deploying remaining infrastructure..."
cd infra
terraform apply -var-file="../${TFVARS_FILE}" -input=false

ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Langfuse is live!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url 2>/dev/null || echo "")

if [ -n "$CLOUDFRONT_URL" ]; then
  echo -e "  URL: ${BLUE}${CLOUDFRONT_URL}${NC}"
elif [ -n "$ALB_DNS" ]; then
  echo -e "  ALB URL: ${BLUE}http://${ALB_DNS}${NC}"
fi
echo ""
