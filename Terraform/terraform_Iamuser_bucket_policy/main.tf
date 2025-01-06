provider "aws" {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

data "aws_s3_bucket" "name" {
    bucket = var.bucket
}

data "aws_iam_user" "name" {
    user_name = var.user_name
}

resource "aws_iam_policy" "name" {
    name = "s3_iam_cli_plocy"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:ListObjects",
                    "s3:GetBucketLocation"
                ],
                Resource = [
                    "${data.aws_s3_bucket.name.arn}",
                    "${data.aws_s3_bucket.name.arn}*/*"
                ]
            },
            {
                Effect = "Allow",
                Action = "s3:ListAllMyBuckets",
                Resource =  "*"
                
            }
        ]
    })

}

resource "aws_iam_user_policy_attachment" "name" {
    user = var.user_name
    policy_arn = aws_iam_policy.name.arn
}