resource "aws_security_group" "debezium-sg" {
  name   = "debezium-sg"
  vpc_id = var.vpc_id
}

# resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

resource "aws_vpc_security_group_ingress_rule" "allow_all_tcp_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_udp_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "udp"
  to_port           = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_internal" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_self" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = aws_security_group.debezium-sg.id
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.debezium-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_external" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.client_sg_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_self" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = aws_security_group.debezium-sg.id
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

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey" # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.kp.key_name}.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.name}-debezium"
  # key_name = aws_key_pair.kp.key_name
  ami = data.aws_ami.ubuntu.id

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.debezium-sg.id]
  instance_type          = "t2.medium"

  user_data = templatefile("modules/debezium/init.sh.tpl", {
    CLIENT_IP = var.client_private_ip
  })
}
