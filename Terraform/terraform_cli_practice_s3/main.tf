# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "console"
    }
  }
}

resource "aws_s3_bucket" "data" {
  bucket_prefix = var.bucket_prefix

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "data" {
  depends_on = [aws_s3_bucket_ownership_controls.data, aws_s3_bucket_public_access_block.data]

  bucket = aws_s3_bucket.data.id
  acl    = "public-read"
}

resource "aws_s3_bucket_ownership_controls" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.data.bucket
  key    = "index.html"
  source = "${var.file_path}index.html"
  acl = "public-read"
  content_type = "text/html"
  
}
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.data.bucket
  key    = "error.html"
  source = "${var.file_path}error.html"
  acl = "public-read"
  content_type = "text/html"
  
}

resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("${var.file_path}", "*")

  bucket = aws_s3_bucket.data.bucket
  key    = each.value
  source = "C:/glps/TTD/${each.value}"
  acl    = "public-read"
  # etag makes the file update when it changes; see https://stackoverflow.com/questions/56107258/terraform-upload-file-to-s3-on-every-apply
  etag   = filemd5("C:/glps/TTD/${each.value}")
}

data "aws_s3_objects" "data" {
  bucket = aws_s3_bucket.data.bucket
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.data.id

  policy = jsonencode({
    "Statement" = [
      {
        "Action" = [
          "s3:GetObject",
          "s3:GetObjectVersion",
        ]
        "Effect"    = "Allow"
        "Principal" = "*"
        "Resource" = [
          "${aws_s3_bucket.data.arn}/*"
          
        ]
        "Sid" = "PublicRead"
      },
    ]
    "Version" = "2012-10-17"
  })
}

