# IAM
# Role to connect to EC2 instances using Session Manager
resource "aws_iam_role" "ssm" {
  name = "ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "instance-profile"
  role = aws_iam_role.ssm.name
}


# Network
resource "aws_vpc" "main" {
  cidr_block = var.main_cidr_block
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route" "main_route_to_internet_gateway" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "main_route_to_peer_vpc" {
  route_table_id            = aws_route_table.main.id
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

resource "aws_vpc_peering_connection" "requester" {
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = aws_vpc.peer.id
  peer_region = var.peer_region
  auto_accept = false

  tags = {
    Name = "vpc-peering-between-main-VPC-and-peer-VPC"
    Side = "requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true

  tags = {
    Side = "accepter"
  }
}

resource "aws_vpc" "peer" {
  provider   = aws.peer
  cidr_block = var.peer_cidr_block
}


resource "aws_subnet" "peer" {
  provider   = aws.peer
  vpc_id     = aws_vpc.peer.id
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "peer-subnet"
  }
}

resource "aws_route_table_association" "peer" {
  provider       = aws.peer
  subnet_id      = aws_subnet.peer.id
  route_table_id = aws_route_table.peer.id
}

resource "aws_route_table" "peer" {
  provider = aws.peer
  vpc_id   = aws_vpc.peer.id

  tags = {
    Name = "peer-route-table"
  }
}

resource "aws_route" "peer_route_to_internet_gateway" {
  provider               = aws.peer
  route_table_id         = aws_route_table.peer.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.peer.id
}

resource "aws_route" "peer_route_to_main_vpc" {
  provider                  = aws.peer
  route_table_id            = aws_route_table.peer.id
  destination_cidr_block    = var.main_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id
}


resource "aws_internet_gateway" "peer" {
  provider = aws.peer
  vpc_id   = aws_vpc.peer.id

  tags = {
    Name = "peer-internet-gateway"
  }
}

# Compute
resource "aws_instance" "main" {
  ami                         = data.aws_ssm_parameter.al2023_minimal_main.value
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
}

resource "aws_security_group" "main" {
  name   = "main-security-group"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "main_allow_ping_from_peer" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = aws_vpc.peer.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  # AWS doesn't support referencing a security group across a peering between two regions.
  # Instead, use `cidr_ipv4`.
  # referenced_security_group_id = aws_security_group.peer.id
}

resource "aws_vpc_security_group_egress_rule" "main_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "peer" {
  provider                    = aws.peer
  ami                         = data.aws_ssm_parameter.al2023_minimal_peer.value
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.peer.id
  vpc_security_group_ids      = [aws_security_group.peer.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
}

resource "aws_security_group" "peer" {
  provider = aws.peer
  name     = "peer-security-group"
  vpc_id   = aws_vpc.peer.id

  tags = {
    Name = "peer-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "peer_allow_ping_from_main" {
  provider          = aws.peer
  security_group_id = aws_security_group.peer.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "peer_allow_all_traffic_ipv4" {
  provider          = aws.peer
  security_group_id = aws_security_group.peer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
