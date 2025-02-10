output "client_private_ip" {
  value = aws_instance.client.private_ip
}

output "client_public_ip" {
  value = aws_instance.client.public_ip
}

output "client_sg_id" {
  description = "Client's SG"
  value       = aws_security_group.client-sg.id
}
