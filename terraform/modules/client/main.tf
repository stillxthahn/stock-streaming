resource "aws_security_group" "client-sg" {
  name   = "client-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow http" {
  security_group_id = aws_security_group.client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "ssh"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow http" {
  security_group_id = aws_security_group.client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name     = var.name
  key_name = "client"

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.client-sg.id]
  instance_type          = "t2.micro"

  user_data                   = file("modules/client/user-data.sh")
  user_data_replace_on_change = true
}
