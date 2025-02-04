resource "aws_security_group" "debezium-sg" {
  name   = "debezium-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_internal" {
  security_group_id            = aws_security_group.debezium-sg.id
  cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_external" {
  security_group_id            = aws_security_group.debezium-sg.id
  cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}


# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv6         = "::/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv6         = "::/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_tcp_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 0
#   ip_protocol       = "tcp"
#   to_port           = 65535
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_udp_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 0
#   ip_protocol       = "udp"
#   to_port           = 65535
# }


# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }


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


module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.name

  ami = data.aws_ami.ubuntu.id

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.debezium-sg.id]
  instance_type          = "t2.micro"

  user_data_base64 = base64encode(templatefile("modules/debezium/init.sh.tpl", {
    CLIENT_IP = var.client_private_ip
  }))
}
