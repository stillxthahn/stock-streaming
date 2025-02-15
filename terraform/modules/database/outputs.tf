output "database_private_ip" {
  value = aws_instance.database.private_ip
}

output "database_public_ip" {
  value = aws_instance.database.public_ip
}

output "database_sg_id" {
  description = "database's SG"
  value       = aws_security_group.database-sg.id
}
