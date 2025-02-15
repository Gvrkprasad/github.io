resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "CloudFrontOAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "webapp_cdn" {
    origin {
        domain_name = aws_s3_bucket.public.bucket_regional_domain_name
        origin_id = "appbucket"
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
    
    enabled = true
    default_root_object = "index.html"
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "appbucket"

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    price_class = "PriceClass_100"
    restrictions {
        geo_restriction {
            restriction_type = "whitelist"
            locations        = ["IN"]  # Restrict to India
        }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
resource "aws_cloudfront_origin_access_identity" "origin_access" {
}
