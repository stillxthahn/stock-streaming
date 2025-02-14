resource "aws_security_group" "client-sg" {
  name   = "client-sg"
  vpc_id = var.vpc_id
}

# resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv6         = "::/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv6         = "::/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

resource "aws_vpc_security_group_ingress_rule" "allow_all_tcp_ipv4" {
  security_group_id = aws_security_group.client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_udp_ipv4" {
  security_group_id = aws_security_group.client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "udp"
  to_port           = 65535
}


# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.name}-client-kp" # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}

# resource "local_file" "ssh_key" {
#   filename        = "${aws_key_pair.kp.key_name}.pem"
#   content         = tls_private_key.pk.private_key_pem
#   file_permission = "0400"
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


resource "aws_instance" "client" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.client-sg.id]

  # key_name = aws_key_pair.kp.key_name

  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   host        = self.public_ip
  #   private_key = tls_private_key.pk.private_key_pem
  # }

  # provisioner "remote-exec" {
  #   script = "modules/client/init.sh"
  # }
  # user_data = file("modules/client/init.sh")
  user_data = templatefile("modules/client/init.sh.tpl", {
    MYSQL_HOST = var.database_host
  })


  tags = {
    Name = "${var.name}-client"
  }

}

