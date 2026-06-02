# AWS Cost Estimate — Langfuse Infrastructure
> **Region:** `ap-northeast-1` (Tokyo) · **Scenario:** 10,000 requests/month · **Duration:** 1 month  
> **Pricing:** AWS Price List API via `awslabs-aws-pricing-mcp-server` MCP · verified 2026-05-21 · updated 2026-05-22  
> **Model:** On-demand, no Reserved Instances or Savings Plans

---

## Total Estimated Monthly Cost: $288.95

| Category | Cost | % |
|----------|------|---|
| ECS Fargate (3 containers) | $143.93 | 50% |
| VPC Interface Endpoints | $81.77 | 28% |
| RDS PostgreSQL | $21.11 | 7% |
| ElastiCache Redis | $18.25 | 6% |
| ALB | $17.75 | 6% |
| Everything else | $6.14 | 2% |
| **TOTAL** | **$288.95** | 100% |

---

## Architecture

```
Internet → CloudFront (free) → ALB → ECS Fargate (Web)
                                           ↓
                                ECS Fargate (Worker)
                                           ↓
                       ┌──────────────────────────────┐
                       │  RDS PostgreSQL  (metadata)  │
                       │  ElastiCache Redis  (cache)  │
                       │  ECS Fargate  (ClickHouse)   │← EFS
                       │  S3  (event storage)         │
                       └──────────────────────────────┘
              Private resources → AWS APIs via VPC Interface Endpoints
```

---

## Service-by-Service Breakdown

### 1. ECS Fargate — $143.93/month (44%)

All containers run **ARM64/Graviton**, 24/7 (730 hours/month).

| Container | vCPU | Memory | Calculation | Cost |
|-----------|------|--------|-------------|------|
| Web (Langfuse UI + API) | 1 | 2 GB | (1×$0.04045 + 2×$0.00442) × 730h | $35.98 |
| Worker (background jobs) | 1 | 2 GB | (1×$0.04045 + 2×$0.00442) × 730h | $35.98 |
| ClickHouse (analytics DB) | 2 | 4 GB | (2×$0.04045 + 4×$0.00442) × 730h | $71.96 |
| | | | **Total** | **$143.93** |

> Rates: $0.04045/vCPU-hr · $0.00442/GB-hr (Graviton, Tokyo — MCP verified)

---

### 2. VPC Interface Endpoints — $81.77/month (28%) ← Largest single cost

4 endpoints × 2 AZs = **8 ENIs × $0.014/hr × 730h**

| Endpoint | Purpose | Monthly |
|----------|---------|---------|
| ECR API | Container image metadata | $20.44 |
| ECR DKR | Container image layers | $20.44 |
| CloudWatch Logs | Log shipping | $20.44 |
| Secrets Manager | Secret fetch at startup | $20.44 |
| Data processing | Minimal at 10k req | ~$0.01 |
| | **Total** | **$81.77** |

> Rate: $0.014/endpoint/AZ/hour (MCP verified)

---

### 3. RDS PostgreSQL — $21.11/month

`db.t4g.micro` · PostgreSQL 16 · Single-AZ · 20 GB gp3

| Component | Calculation | Cost |
|-----------|-------------|------|
| Instance hours | $0.025/hr × 730h | $18.25 |
| Storage (gp3) | 20 GB × $0.138/GB-mo | $2.76 |
| Automated backups | 7-day retention (est.) | $0.10 |
| | **Total** | **$21.11** |

---

### 4. ElastiCache Redis — $18.25/month

`cache.t4g.micro` · Redis 7.1 · Single node

| Calculation | Cost |
|-------------|------|
| $0.025/hr × 730h | **$18.25** |

---

### 5. ALB (Application Load Balancer) — $17.75/month

| Component | Calculation | Cost |
|-----------|-------------|------|
| Fixed hourly | $0.0243/hr × 730h | $17.74 |
| LCU (10,000 req) | Negligible at this scale | $0.01 |
| | **Total** | **$17.75** |

---

### 6. Secrets Manager — $2.40/month

6 secrets: `database-url`, `nextauth-secret`, `salt`, `encryption-key`, `clickhouse-password`, `cognito-client-secret`

| Calculation | Cost |
|-------------|------|
| 6 × $0.40/secret | **$2.40** |

---

### 7. EFS (ClickHouse storage) — $1.80/month

Persistent data volume for ClickHouse at `/var/lib/clickhouse`, Standard storage class.

| Calculation | Cost |
|-------------|------|
| ~5 GB × $0.36/GB-mo | **$1.80** |

---

### 8. CloudWatch Logs — $1.00/month

3 log groups (`/ecs/langfuse/web`, `/ecs/langfuse/worker`, `/ecs/langfuse/clickhouse`) · 30-day retention each.

| Component | Cost |
|-----------|------|
| Log ingestion (~100 MB) | $0.08 |
| Container Insights metrics | $0.92 |
| **Total** | **$1.00** |

---

### 9. Route53 — $0.50/month

| Component | Cost |
|-----------|------|
| 1 hosted zone (custom domain) | **$0.50** |

---

### 10. ECR — $0.40/month

3 repositories: `langfuse/web`, `langfuse/worker`, `langfuse/clickhouse`

| Calculation | Cost |
|-------------|------|
| ~4 GB × $0.10/GB-mo | **$0.40** |

---

### 11. S3 — $0.05/month

Event storage · lifecycle to Intelligent Tiering after 60 days.

| Component | Calculation | Cost |
|-----------|-------------|------|
| Storage (~10 MB) | Negligible | ~$0.00 |
| PUT requests | 10,000 × $0.0047/1k | $0.05 |
| | **Total** | **$0.05** |

---

### 12. CloudFront — $0.00 ✅ Free Tier

10,000 requests is 1% of the 1M/month free tier. Data transfer (~10 MB) is well within the 100 GB/month free allowance.

### 13. Cognito — $0.00 (at 10,000 MAUs or under)

New User Pools use the **Lite Plan** with a **10,000 MAU free tier**.

| MAUs | Cost |
|------|------|
| ≤ 10,000 | **$0.00** (free tier) |
| 10,001 – 90,000 | $0.0055/MAU above 10,000 |
| 90,001 – 990,000 | $0.0046/MAU |

At 10,000 requests/month the MAU count depends on how many unique users log in. If all 10,000 requests come from unique users (worst case) = exactly at the free tier limit = **$0.00**. Any users beyond 10,000 MAUs cost $0.0055 each.

> Rate source: `APN1-CognitoLiteMAU` · MCP verified 2026-05-21

---

## Full Cost Summary

| # | Service | Config | Monthly Cost |
|---|---------|--------|-------------|
| 1 | ECS Fargate – Web | 1 vCPU · 2 GB · ARM64 · 24/7 | $35.98 |
| 2 | ECS Fargate – Worker | 1 vCPU · 2 GB · ARM64 · 24/7 | $35.98 |
| 3 | ECS Fargate – ClickHouse | 2 vCPU · 4 GB · ARM64 · 24/7 | $71.96 |
| 4 | VPC Interface Endpoints | 4 endpoints × 2 AZs | $81.77 |
| 5 | RDS PostgreSQL | db.t4g.micro · 20 GB gp3 · Single-AZ | $21.11 |
| 6 | ElastiCache Redis | cache.t4g.micro · single node | $18.25 |
| 7 | ALB | 1 Application Load Balancer | $17.75 |
| 8 | Secrets Manager | 6 secrets | $2.40 |
| 9 | EFS | ~5 GB Standard | $1.80 |
| 10 | CloudWatch Logs | 3 log groups · 30-day retention | $1.00 |
| 11 | Route53 | 1 hosted zone | $0.50 |
| 12 | ECR | 3 repos · ~4 GB | $0.40 |
| 13 | S3 | ~10 MB + 10,000 PUTs | $0.05 |
| 14 | CloudFront | 10,000 req (free tier) | $0.00 |
| 15 | Cognito | ≤ 10,000 MAU (free tier) | $0.00 |
| | | **GRAND TOTAL** | **$288.95** |

---

## Key Notes

**Costs are mostly fixed, not traffic-driven.**  
Almost everything runs 24/7 regardless of request volume.
- At 10,000 req/month → **$0.033 per request**
- At 1,000,000 req/month → **$0.0003 per request**

**VPC Endpoints are the hidden cost.**  
At $81.77/month (down from $122.65 after removing SES + Cognito endpoints) they still cost more than RDS + Redis combined. They replaced a NAT Gateway but are more expensive at low traffic.

---

## Cost Optimization Opportunities

| Action | Monthly Saving |
|--------|---------------|
| Reduce all endpoints to 1 AZ | $40 |
| Scale Worker to 0 when idle | $36 |
| Reduce CloudWatch Container Insights retention | $5–15 |
| Compute Savings Plan (after 60 days stable usage) | 20–40% on Fargate |

---

## Assumptions

- On-demand pricing, no commitments
- 730 hours/month, all Fargate tasks ARM64/Graviton
- EFS ~5 GB for ClickHouse data at 10,000 events
- CloudFront and Cognito within always-free tiers
- Custom domain via Route53 included
