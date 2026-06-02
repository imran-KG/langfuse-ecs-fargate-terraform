#!/bin/bash
# =============================================================================
# Push container images from Docker Hub to ECR
# =============================================================================
# ECR repositories are created by Terraform. Run this script after
# `terraform apply` to push images before ECS tasks start.
#
# Usage:
#   ./infra/modules/ecr/push-images.sh <aws_account_id> <aws_region> [service_name] [aws_profile]
#
# Examples:
#   ./infra/modules/ecr/push-images.sh 123456789012 ap-northeast-1
#   ./infra/modules/ecr/push-images.sh 123456789012 ap-northeast-1 langfuse my-aws-profile
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 <aws_account_id> <aws_region> [service_name] [aws_profile]${NC}"
    echo "Example: $0 123456789012 ap-northeast-1 langfuse my-aws-profile"
    exit 1
fi

AWS_ACCOUNT_ID="$1"
AWS_REGION="$2"
SERVICE_NAME="${3:-langfuse}"
AWS_PROFILE="${4:-}"
LANGFUSE_VERSION="${5:-}"
CLICKHOUSE_VERSION="${6:-}"
LANGFUSE_WORKER_VERSION="${7:-}"

# Apply profile for all AWS CLI calls in this script
if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE
fi

ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Image versions — driven by tfvars via deploy.sh
LANGFUSE_WEB_ECR_TAG="${LANGFUSE_VERSION:-3}"
LANGFUSE_WORKER_ECR_TAG="${LANGFUSE_WORKER_VERSION:-${LANGFUSE_WEB_ECR_TAG}}"
CLICKHOUSE_ECR_TAG="${CLICKHOUSE_VERSION:-24}"

# Source images from Docker Hub
LANGFUSE_WEB_SOURCE="langfuse/langfuse:${LANGFUSE_WEB_ECR_TAG}"
LANGFUSE_WORKER_SOURCE="langfuse/langfuse-worker:${LANGFUSE_WORKER_ECR_TAG}"
CLICKHOUSE_SOURCE="clickhouse/clickhouse-server:${CLICKHOUSE_ECR_TAG}"

# Target ECR repositories (created by Terraform as {service_name}/web etc.)
ECR_WEB_URL="${ECR_BASE}/${SERVICE_NAME}/web"
ECR_WORKER_URL="${ECR_BASE}/${SERVICE_NAME}/worker"
ECR_CLICKHOUSE_URL="${ECR_BASE}/${SERVICE_NAME}/clickhouse"

# Target architecture (ARM64 for Fargate Graviton)
PLATFORM="linux/arm64"

PROFILE_MSG="${AWS_PROFILE:-default}"
echo -e "${GREEN}=== ECR Image Push Script ===${NC}"
echo "AWS Account : ${AWS_ACCOUNT_ID}"
echo "AWS Region  : ${AWS_REGION}"
echo "AWS Profile : ${PROFILE_MSG}"
echo "Service Name: ${SERVICE_NAME}"
echo "Platform    : ${PLATFORM}"
echo ""
echo "Target repositories:"
echo "  - ${ECR_WEB_URL}:${LANGFUSE_WEB_ECR_TAG}"
echo "  - ${ECR_WORKER_URL}:${LANGFUSE_WORKER_ECR_TAG}"
echo "  - ${ECR_CLICKHOUSE_URL}:${CLICKHOUSE_ECR_TAG}"
echo ""

echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_BASE}"

push_image() {
    local source_image="$1"
    local ecr_url="$2"
    local tag="$3"
    local name="$4"

    echo ""
    echo -e "${YELLOW}Processing ${name}...${NC}"
    echo "  Pulling ${source_image} for ${PLATFORM}..."
    docker pull --platform "${PLATFORM}" "${source_image}"
    echo "  Tagging as ${ecr_url}:${tag}..."
    docker tag "${source_image}" "${ecr_url}:${tag}"
    echo "  Pushing to ECR..."
    docker push "${ecr_url}:${tag}"
    echo -e "  ${GREEN}Done!${NC}"
}

push_image "${LANGFUSE_WEB_SOURCE}"    "${ECR_WEB_URL}"        "${LANGFUSE_WEB_ECR_TAG}"     "Langfuse Web"
push_image "${LANGFUSE_WORKER_SOURCE}" "${ECR_WORKER_URL}"     "${LANGFUSE_WORKER_ECR_TAG}"  "Langfuse Worker"
push_image "${CLICKHOUSE_SOURCE}"      "${ECR_CLICKHOUSE_URL}" "${CLICKHOUSE_ECR_TAG}" "ClickHouse"

echo ""
echo -e "${GREEN}=== All images pushed successfully! ===${NC}"
