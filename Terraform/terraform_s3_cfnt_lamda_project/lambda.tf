resource "aws_lambda_function" "copy_s3_objects" {
  function_name = "copy_s3_objects"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 40
  filename      = "lambda.zip"
  environment {
    variables = {
      SOURCE_BUCKET_NAME = aws_s3_bucket.public.id
      DESTINATION_BUCKET_NAME = aws_s3_bucket.private.id
  }
}
}  