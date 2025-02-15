# s3_bucket block of bucket_1:"dorababu-terraform-bucket"
resource "aws_s3_bucket" "bucket_1" {
  bucket = var.bucket_name
  
  tags = {
    Name = var.environment
  }
  force_destroy = true

}

resource "aws_s3_bucket_ownership_controls" "bucket_1" {
  bucket = aws_s3_bucket.bucket_1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_1" {
  bucket = aws_s3_bucket.bucket_1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_1" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_1,
    aws_s3_bucket_public_access_block.bucket_1,
  ]

  bucket = aws_s3_bucket.bucket_1.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "bucket_1" {
  bucket = aws_s3_bucket.bucket_1.id
  versioning_configuration {
    status = "Enabled"
  }

}    

# To delete the latest version of the objects is s3_bucket
/*
resource "null_resource" "delete_latest_version" {
  provisioner "local-exec" {
    command = <<EOT
      aws s3api delete-object --bucket dorababu-terraform-bucket --key terraform.tfstate
       --version-id $(aws s3api list-object-versions --bucket dorababu-terraform-bucket 
       --prefix terraform.tfstate --query 'Versions[0].VersionId' --output table)
    EOT
  }
}
*/


# s3_bucket block of bucket_2: "environments"
resource "aws_s3_bucket" "env_bucket" {
  bucket = var.env_bucket_name

  tags = {
    Name = var.environment
  }
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "env_bucket" {
  bucket = aws_s3_bucket.env_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "env_bucket" {
  bucket = aws_s3_bucket.env_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "env_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.env_bucket,
    aws_s3_bucket_public_access_block.env_bucket,
  ]

  bucket = aws_s3_bucket.env_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "env_bucket" {
  bucket = aws_s3_bucket.env_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

}    