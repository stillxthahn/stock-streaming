output "client_public_ip" {
  value = aws_instance.client.public_ip
}

output "database_private_ip" {
  value = aws_instance.database.private_ip
}

output "debezium_private_ip" {
  value = aws_instance.debezium.private_ip
}

output "spark_private_ip" {
  value = aws_instance.spark.private_ip
}
