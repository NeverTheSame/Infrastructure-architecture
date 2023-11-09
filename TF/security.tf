resource "aws_security_group" "dev_security_group" {
  name        = "dev_security_group"
  description = "Security group to control inbound/outbound traffic"

  # Skipping VPC to deploy to the region's default VPC for the sake of time savings.

  # Ingress rules (inbound traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  # Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rds_ingress" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = [aws_subnet.private_subnet.cidr_block] 
  security_group_id = aws_db_instance.dev_rds.security_group_names[0] 
}

# Configure WAF (Web Application Firewall) for frontend protection.
resource "aws_wafv2_web_acl" "dev-waf" {
  name        = "dev-waf"
  description = "Web Application Firewall blocking geo locations"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["US", "CA"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}
