output "debezium_private_ip" {
  value = aws_instance.debezium.private_ip
}

output "debezium_public_ip" {
  value = aws_instance.debezium.public_ip
}

output "debezium_sg_id" {
  description = "debezium's SG"
  value       = aws_security_group.debezium-sg.id
}
