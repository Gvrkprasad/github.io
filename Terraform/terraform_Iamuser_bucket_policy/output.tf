# Output Values

output "s3_bucket_name" {
    description = "Name of our S3 bucket."
    value       = data.aws_s3_bucket.name.bucket
}
output "s3_iam_policy" {
    description = "The S3 bucket policy."
    value       = aws_iam_policy.name.policy
}