resource "aws_security_group" "web" {
  name_prefix = "web-sg-"
  description = "Web security group"

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
    Name = "web-ingress-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "web" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"

  tags = {
    Name = "web-egress-app"
  }
}

resource "aws_instance" "web" {
  count = length(var.allowed_availability_zones)

  ami                    = data.aws_ssm_parameter.al2023_minimal.value
  instance_type          = "t2.micro"
  availability_zone      = var.allowed_availability_zones[count.index]
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "web"
  }
}
