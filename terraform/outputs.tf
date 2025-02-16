output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "client_public_ip" {
  value = module.ec2.client_public_ip
}

output "database_private_ip" {
  value = module.ec2.database_private_ip
}

output "debezium_private_ip" {
  value = module.ec2.debezium_private_ip
}

output "spark_private_ip" {
  value = module.ec2.spark_private_ip
}



