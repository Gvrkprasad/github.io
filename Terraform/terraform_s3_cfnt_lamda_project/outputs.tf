output "website_url" {
  value       = "https://${aws_cloudfront_distribution.webapp_cdn.domain_name}"
  description = "CloudFront distribution URL"
}

output "app_bucket_url" {
  value       = "https://${aws_s3_bucket.public.bucket_regional_domain_name}"
  description = "App bucket URL"
}