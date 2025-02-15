resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  )
} 
resource "aws_iam_policy" "s3_copy_policy" {
  name = "s3_copy_policy"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": ["s3:PutObject", "s3:PutObjectAcl"],
          "Effect": "Allow",
          "Resource": "${aws_s3_bucket.public.arn}/*"
        },
        {
          "Action"  : ["s3:PutObject", "s3:CopyObject"],
          "Effect"  : "Allow",
          "Resource" : "${aws_s3_bucket.private.arn}/*"
      }
      ]
    })
}
resource "aws_iam_role_policy_attachment" "s3_copy_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_copy_policy.arn
}
  