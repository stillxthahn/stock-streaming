module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.name

  instance_type = "t2.micro"
  # vpc_security_group_ids = ["sg-12345678"]
  subnet_id = var.public_subnet_id
}
