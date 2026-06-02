# =============================================================================
# Application Load Balancer for Langfuse Web
# =============================================================================
# HTTP only — TLS termination is handled by CloudFront.
# Inbound restricted to CloudFront origin-facing IP ranges.
# =============================================================================

# CloudFront managed prefix list (origin-facing IPs used to reach ALB)
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# ALB
resource "aws_lb" "main" {
  count = var.enable_alb ? 1 : 0

  name               = "${var.service_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.service_name}-alb"
  }
}

# ALB Security Group — HTTP from CloudFront only
resource "aws_security_group" "alb" {
  count = var.enable_alb ? 1 : 0

  name        = "${var.service_name}-alb"
  description = "Security group for ALB - CloudFront origin-facing only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from CloudFront origin-facing IPs"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  count = var.enable_alb ? 1 : 0

  name        = "${var.service_name}-web-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/public/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.service_name}-web-tg"
  }
}

# HTTP Listener — CloudFront connects on port 80
resource "aws_lb_listener" "http" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }
}

# Allow traffic from ALB into Web ECS tasks
resource "aws_security_group_rule" "web_from_alb" {
  count = var.enable_alb ? 1 : 0

  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb[0].id
  security_group_id        = var.web_security_group_id
  description              = "Allow traffic from ALB"
}

# =============================================================================
# Route53 DNS Record (optional - for custom domain pointing directly to ALB)
# =============================================================================
resource "aws_route53_record" "langfuse" {
  count = var.enable_alb && var.custom_domain != "" && var.route53_zone_id != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.custom_domain
  type    = "A"

  alias {
    name                   = aws_lb.main[0].dns_name
    zone_id                = aws_lb.main[0].zone_id
    evaluate_target_health = true
  }
}
