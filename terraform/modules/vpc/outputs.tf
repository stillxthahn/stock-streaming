output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public-01.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private-01.id, aws_subnet.private-02.id]
}
