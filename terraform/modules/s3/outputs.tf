output "s3_stock_bucket_endpoint" {
  description = "S3 datalake's endpoint"
  value       = aws_s3_bucket.stock.bucket_regional_domain_name
}
