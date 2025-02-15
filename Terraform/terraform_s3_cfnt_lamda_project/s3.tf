# ✅ App Bucket (Static Website)
# Creates an S3 bucket for hosting the static website files
# The bucket name is appbucket-{random-suffix} to ensure uniqueness #
resource "aws_s3_bucket" "public" {
  bucket = "appbucket-${random_id.suffix.hex}"
  tags = {
    Name        = "appbucket"
    Environment = "Dev" 
    Access = "Public"
  }
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "public" {
 for_each = fileset("Frontend/", "**")
  bucket   = aws_s3_bucket.public.id
  key      = each.value
  source   = "Frontend/${each.value}"

  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript" },
    split(".", each.value)[length(split(".", each.value)) - 1], "binary/octet-stream")  

  etag = filemd5("Frontend/${each.value}")  
}

# ✅ Website Configuration
# Configures the S3 bucket for static website hosting
# Sets index.html as the default page and error.html for error responses
resource "aws_s3_bucket_website_configuration" "main" {
    bucket = aws_s3_bucket.public.id
    
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }   
}

# ✅ Private Patches Bucket
resource "aws_s3_bucket" "private" {
  bucket = "patchesprivatebucket-${random_id.suffix.hex}"
  tags = {
    Name = "patchesprivatebucket"
    Environment = "Dev"    
    Access = "private"
  }
}

resource "aws_s3_bucket_ownership_controls" "private" {
  bucket = aws_s3_bucket.private.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "private" {
 for_each = fileset("Frontend/", "**")
  bucket   = aws_s3_bucket.private.id
  key      = each.value
  source   = "Frontend/${each.value}"

  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript" },
    split(".", each.value)[length(split(".", each.value)) - 1], "binary/octet-stream")  
  etag = filemd5("Frontend/${each.value}")  
}

# ✅ Bucket Policy (Public Read for App Bucket)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
         Service = "cloudfront.amazonaws.com"
         }
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.public.arn,
          "${aws_s3_bucket.public.arn}/*"
        ]
        "Condition": {
        "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::816069156122:distribution/E191YLIT8UF2XM"
        }
        }
      }
    ]
  })

}

# ✅ Generates a random 4-byte suffix to make the bucket name unique
resource "random_id" "suffix" {
  byte_length = 4
}