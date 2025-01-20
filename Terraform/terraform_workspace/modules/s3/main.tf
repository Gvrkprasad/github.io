resource "aws_s3_bucket" "bucket" {
    
    bucket = var.bucket_name
    
    tags = {
        Name = "${var.environment}-babu"
    }
    force_destroy = true

}

resource "aws_s3_bucket_versioning" "bucket_version" {
    bucket = aws_s3_bucket.bucket.id
    versioning_configuration {
      status = "Enabled"
    }
 
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.bucket.id

    rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

