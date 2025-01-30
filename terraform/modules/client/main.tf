module "ec2_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name     = var.name
  key_name = "client"

  instance_type = "t2.micro"
  # vpc_security_group_ids = ["sg-12345678"]

  # user_data_base64            = base64encode(local.user_data)
  user_data                   = file("modules/client/user-data.sh")
  user_data_replace_on_change = true

  subnet_id = var.public_subnet_id
}
