output "s3_bucket" {
  value = aws_s3_bucket.bucket_1.id
}
output "s3_env_bucket" {
  value = aws_s3_bucket.env_bucket.id
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.bucket_1.arn
}
output "s3_env_bucket_arn" {
  value = aws_s3_bucket.env_bucket.arn
}