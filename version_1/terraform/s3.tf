resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_name}-uploads-${random_id.bucket_suffix}"
}

#wires up event notification to trigger the lambda function
resource "aws_s3_bucket_notification" "csv_upload" {
  bucket = aws_s3_bucket.uploads.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.student_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "submissions/"
    filter_suffix       = ".csv"
  }
}

# Without this, S3 events silently fail to trigger the Lambda - S3 needs
# explicit permission to invoke it, scoped to this specific bucket.
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}