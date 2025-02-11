resource "aws_security_group" "spark-sg" {
  name   = "spark-sg"
  vpc_id = var.vpc_id
}

# resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.spark-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_tcp_ipv4" {
#   security_group_id = aws_security_group.spark-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 0
#   ip_protocol       = "tcp"
#   to_port           = 65535
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_udp_ipv4" {
#   security_group_id = aws_security_group.spark-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 0
#   ip_protocol       = "udp"
#   to_port           = 65535
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.spark-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_internal" {
  security_group_id            = aws_security_group.spark-sg.id
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.debezium_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.spark-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_external" {
  security_group_id            = aws_security_group.spark-sg.id
  ip_protocol                  = "-1" # semantically equivalent to all ports
  referenced_security_group_id = var.debezium_sg_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.spark-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
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
  key_name   = "${var.name}-spark-kp" # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}


resource "aws_instance" "spark" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.spark-sg.id]

  user_data = templatefile("modules/spark/init.sh.tpl", {
    KAFKA_BROKERS         = "${var.debezium_private_ip}:9092"
    KAFKA_TOPICS          = "dbserver1.STOCK_STREAMING.IBM_STOCK"
    REGION                = var.region
    AWS_ACCESS_KEY_ID     = var.access_key
    AWS_SECRET_ACCESS_KEY = var.secret_key
  })


  tags = {
    Name = "${var.name}-spark"
  }
}

