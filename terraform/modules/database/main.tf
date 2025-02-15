resource "aws_security_group" "database-sg" {
  name   = "database-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_tcp_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_udp_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "udp"
  to_port           = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_internal_client" {
  security_group_id = aws_security_group.database-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_internal_debezium" {
  security_group_id = aws_security_group.database-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.debezium_sg_id
}


resource "aws_vpc_security_group_egress_rule" "allow_all_tcp_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_udp_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "udp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.database-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_external_client" {
  security_group_id            = aws_security_group.database-sg.id
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_external_debezium" {
  security_group_id            = aws_security_group.database-sg.id
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.debezium_sg_id
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"] #Ubuntu Server 22.04 LTS (HVM)
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}


resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.database-sg.id]
  user_data              = file("modules/database/init.sh")


  tags = {
    Name = "${var.name}-database"
  }
}

