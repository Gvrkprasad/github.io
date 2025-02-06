# Creating S3 bucket to store frontend data
resource "aws_s3_bucket" "bkt" {
    bucket = var.bucket_name
    
    tags = {
        Name = "${var.environment}_bucket"
    }
    force_destroy = true
}


# Enabling versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "bkt" {
    bucket = aws_s3_bucket.bkt.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Setting ownership controls for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "bkt" {
    bucket = aws_s3_bucket.bkt.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# Configuring public access block settings for the S3 bucket
resource "aws_s3_bucket_public_access_block" "bkt" {
    bucket = aws_s3_bucket.bkt.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

# Setting ACL for the S3 bucket to public-read
resource "aws_s3_bucket_acl" "bkt" {
    depends_on = [
        aws_s3_bucket_ownership_controls.bkt,
        aws_s3_bucket_public_access_block.bkt,
    ]

    bucket = aws_s3_bucket.bkt.id
    acl    = "public-read"
}

# Configuring website settings for the S3 bucket
resource "aws_s3_bucket_website_configuration" "example" {
    bucket = aws_s3_bucket.bkt.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

resource "aws_s3_object" "lambda_object" {
   for_each = fileset("${var.s3object_path}", "**/*") 
  bucket = aws_s3_bucket.bkt.bucket
  key = each.value
  source = "${var.s3object_path}/${each.value}"

  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "json" = "application/json"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "binary/octet-stream")
#  acl    = "public-read"
  etag   = filemd5("${var.s3object_path}/${each.value}")
  cache_control = contains([".html", "/index.html"], each.value) ? "no-cache" : "max-age=31536000, public"

 
  metadata = {
    # For CSS, JS, and other static files
    "cache-control" = lookup({
      "css" = "max-age=31536000, public",
      "js"  = "max-age=31536000, public"
    }, split(".", each.value)[length(split(".", each.value)) - 1], "no-cache")

  /*
    # For HTML files
    "x-amz-meta-cache-control" = lookup({
      "html" = "max-age=3600, must-revalidate"
    }, split(".", each.value)[length(split(".", each.value)) - 1], "no-cache") */
  }

  # Optional ACL (if needed)
  # acl = "public-read" 
}




resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.bkt.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["x-content-type-options"]
    max_age_seconds = 3000
  }

  
}
