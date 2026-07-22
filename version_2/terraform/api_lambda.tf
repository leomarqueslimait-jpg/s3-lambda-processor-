# Zips the lambda_api/ folder (handler.py + student.py) - this is the
# HTTP-facing Lambda the static form POSTs to, separate from the
# S3-triggered processor Lambda in lambda.tf.

data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda_api"
  output_path = "${path.module}/build/api_function.zip"
}

resource "aws_lambda_function" "form_api" {
  function_name = "${var.project_name}-api"
  role          = aws_iam_role.api_lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 10

  filename         = data.archive_file.api_lambda_zip.output_path
  source_code_hash = data.archive_file.api_lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.uploads.id
    }
  }
}
