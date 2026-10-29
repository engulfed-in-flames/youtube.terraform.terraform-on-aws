# 1. prevent_destroy
resource "aws_s3_bucket" "compliance" {
  bucket = "${local.bucket_name}-compliance"
  tags = {
    Name = "${local.bucket_name}-compliance"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${local.name_prefix}-web-sg-"
  description = "Web security group"
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
  description       = "HTTP from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  tags = {
    Name = "${local.name_prefix}-web-ingress-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "web" {
  security_group_id            = aws_security_group.web.id
  description                  = "Traffic to the app tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
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

# 2. create_before_destroy, replace_triggered_by
resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023_minimal.value
  instance_type          = var.allowed_instance_types[var.environment]
  vpc_security_group_ids = [aws_security_group.web.id]
  tags = {
    Name = "${local.name_prefix}-web"
  }

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [aws_security_group.web.id]
  }
}

resource "aws_launch_template" "app" {
  name_prefix            = "${local.name_prefix}-lt-"
  image_id               = data.aws_ssm_parameter.al2023_minimal.value
  instance_type          = var.allowed_instance_types[var.environment]
  vpc_security_group_ids = [aws_security_group.app.id] # SG change -> new template version
  update_default_version = true
}

# Ignore_changes
resource "aws_autoscaling_group" "app" {
  name               = "${local.name_prefix}-asg"
  min_size           = 1
  max_size           = 3
  desired_capacity   = 1
  availability_zones = var.allowed_availability_zones

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # Rolling refresh whenever the launch template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Precondition
resource "aws_s3_bucket" "regional" {
  bucket = "${local.bucket_name}-regional"
  tags = {
    Name = "${local.bucket_name}-regional"
  }

  lifecycle {
    precondition {
      condition     = contains(["ap-northeast-1"], var.region)
      error_message = "This bucket can only be created in a Japan region."
    }
  }
}

# Postcondition
resource "aws_s3_bucket" "tagged" {
  bucket = "${local.bucket_name}-tagged"
  tags = {
    Name = "${local.bucket_name}-tagged"
  }

  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags_all), "Project")
      error_message = "Bucket must have an Project tag."
    }
  }
}
