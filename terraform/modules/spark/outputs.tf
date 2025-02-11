output "spark_private_ip" {
  value = aws_instance.spark.private_ip
}

output "spark_public_ip" {
  value = aws_instance.spark.public_ip
}

output "spark_sg_id" {
  description = "Spark's SG"
  value       = aws_security_group.spark-sg.id
}
