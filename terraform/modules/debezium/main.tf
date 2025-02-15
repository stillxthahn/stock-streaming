resource "aws_security_group" "debezium-sg" {
  name   = "debezium-sg"
  vpc_id = var.vpc_id
}


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_database" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.database_sg_id
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.debezium-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_database" {
  security_group_id = aws_security_group.debezium-sg.id
  # cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.database_sg_id
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


resource "aws_instance" "debezium" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.debezium-sg.id]

  user_data = templatefile("modules/debezium/init.sh.tpl", {
    MYSQL_HOST = var.database_host
  })

  tags = {
    Name = "${var.name}-debezium"
  }
}

