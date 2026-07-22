# Zips the lambda/ folder (handler.py + student.py) into a deployment package.

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/build/function.zip"
}

resource "aws_lambda_function" "student_processor" {
  function_name = "${var.project_name}-processor"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler" # file.function_name inside the zip
  runtime       = var.lambda_runtime

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 # forces redeploy when code changes

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.students.name
    }
  }
}


