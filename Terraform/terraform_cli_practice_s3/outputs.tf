# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output values

output "s3_bucket_name" {
  description = "Name of our S3 bucket."
  value       = aws_s3_bucket.data.bucket
}
output "aws_s3_bucket_data" {
  description = "The S3 bucket."
  value       = [aws_s3_bucket.data.arn , aws_s3_bucket.data.region , aws_s3_bucket.data.website_endpoint]
  
}