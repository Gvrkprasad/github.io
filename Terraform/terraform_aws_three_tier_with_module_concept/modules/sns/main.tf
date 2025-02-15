data "aws_s3_bucket" "env_bucket" {
  bucket=var.env_bucket_name
}


resource "aws_sns_topic" "s3_object_sns" {
  name = "s3_obeject_sns_topic"
  policy = data.aws_iam_policy_document.name.json
}

resource "aws_sns_topic_subscription" "s3_object_sns" {
  topic_arn = aws_sns_topic.s3_object_sns.arn
  protocol  = "email-json"          #sms,lamda deliver options
  endpoint  = "glpsk370@gmail.com"
}

data "aws_iam_policy_document" "name" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:s3_obeject_sns_topic"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.env_bucket.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.env_bucket.bucket

  topic {
    topic_arn     = aws_sns_topic.s3_object_sns.arn
    events        = ["s3:ObjectCreated:*"]
  #  filter_prefix = "*."
  #  filter_suffix = ".*"  # will receive if .jpg object_upload notifications
  }
  eventbridge = true
}

resource "aws_s3_object" "object" {
  bucket = data.aws_s3_bucket.env_bucket.bucket
  key    = "SG.png"
  source = var.file_path
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  content_type = "text/html"
  acl = "public-read"
}