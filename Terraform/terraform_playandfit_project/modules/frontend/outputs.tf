output "s3_bucket_name" {
    value = aws_s3_bucket.bkt.id
}
output "s3_bucket_arn" {
    value = aws_s3_bucket.bkt.arn
}

output "s3_static_url2" {
  value = aws_s3_bucket_website_configuration.example.website_endpoint
}