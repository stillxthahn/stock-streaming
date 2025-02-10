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

output "client_private_ip" {
  value = module.client.client_private_ip
}

output "client_public_ip" {
  value = module.client.client_public_ip
}

output "debezium_private_ip" {
  value = module.debezium.debezium_private_ip
}

output "debezium_public_ip" {
  value = module.debezium.debezium_public_ip
}

