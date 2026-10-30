# 1. Conditional Expressions
resource "aws_security_group" "web" {
  name_prefix = "${local.name_prefix}-web-sg-"
  description = "Web security group"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-sg-"
  description = "App security group"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  security_group_id = aws_security_group.web.id
  description       = local.is_prod ? "HTTPS from the internet" : "HTTP from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = local.is_prod ? 443 : 80
  to_port           = local.is_prod ? 443 : 80
  ip_protocol       = "tcp"
  tags = {
    Name = "${local.name_prefix}-web-ingress-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "web" {
  security_group_id            = aws_security_group.web.id
  description                  = "All outbound traffic"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 0
  to_port                      = 0
  ip_protocol                  = "-1"
  tags = {
    Name = "${local.name_prefix}-web-egress-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id            = aws_security_group.app.id
  description                  = "Traffic from the web tier"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  tags = {
    Name = "${local.name_prefix}-app-ingress-web"
  }
}

resource "aws_vpc_security_group_egress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS for package updates and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  tags = {
    Name = "${local.name_prefix}-app-egress-https"
  }
}

resource "aws_instance" "web" {
  count = length(var.allowed_availability_zones)

  ami                    = data.aws_ssm_parameter.al2023_minimal.value
  instance_type          = local.is_prod ? var.allowed_instance_types["prod"] : var.allowed_instance_types["dev"]
  availability_zone      = var.allowed_availability_zones[count.index]
  vpc_security_group_ids = [aws_security_group.web.id]
  # monitoring             = local.is_prod

  root_block_device {
    volume_type = "gp3"
    volume_size = local.is_prod ? 30 : 8
    encrypted   = true
  }

  tags = {
    Name = "${local.name_prefix}-web-${count.index + 1}"
  }
}

resource "aws_launch_template" "app" {
  name_prefix            = "${local.name_prefix}-lt-"
  image_id               = data.aws_ssm_parameter.al2023_minimal.value
  instance_type          = var.allowed_instance_types[var.environment]
  vpc_security_group_ids = [aws_security_group.app.id]
  update_default_version = true
}

# 2. Dynamic block
resource "aws_autoscaling_group" "app" {
  name               = "${local.name_prefix}-asg"
  min_size           = local.is_prod ? 2 : 1
  max_size           = local.is_prod ? 6 : 2
  desired_capacity   = local.is_prod ? 2 : 1
  availability_zones = var.allowed_availability_zones

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # ASG instances don't inherit provider default_tags, so propagate every common tag explicitly
  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# 3. Splat expression
resource "aws_s3_bucket" "compliance" {
  bucket = "${local.bucket_name}-compliance"
  tags = {
    Name = "${local.bucket_name}-compliance"
  }
}

resource "aws_s3_bucket" "logs" {
  count = local.is_prod ? 1 : 0

  bucket = "${local.bucket_name}-logs"
  tags = {
    Name = "${local.bucket_name}-logs"
  }
}

resource "aws_s3_bucket_logging" "compliance" {
  count = length(aws_s3_bucket.logs)

  bucket        = aws_s3_bucket.compliance.id
  target_bucket = one(aws_s3_bucket.logs[*].id)
  target_prefix = "compliance/"
}
