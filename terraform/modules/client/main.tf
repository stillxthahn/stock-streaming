resource "aws_security_group" "client-sg" {
  name   = "client-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
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

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.client-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }


data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-04b4f1a9cf54c11d0"] #Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  }
  # filter {
  #   name   = "virtualization-type"
  #   values = ["hvm"]
  # }

  owners = ["099720109477"]
}


module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.name

  ami = data.aws_ami.ubuntu.id

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.client-sg.id]
  instance_type          = "t2.micro"

  user_data                   = file("modules/client/user-data.sh")
  user_data_replace_on_change = true
}
