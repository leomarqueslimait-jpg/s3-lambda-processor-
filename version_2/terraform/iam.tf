# Trust policy:
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Permission polic1y 1:

# AWS-managed policy: grants lambda_exec role permission to - logs:CreateLogGroup,
# logs:CreateLogStream, logs:PutLogEvents

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permission policy 2:
#in line policy:
# two actions the handler needs, on exactly this bucket and
# this table - not broad S3/DynamoDB access.

#JSON file
data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    sid       = "ReadUploadedCsv"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }

  statement {
    sid       = "WriteStudentRecords"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.students.arn]
  }
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "${var.project_name}-lambda-permissions"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

# --- API Lambda role (the form's HTTP-facing entry point) ---

resource "aws_iam_role" "api_lambda_exec" {
  name               = "${var.project_name}-api-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_lambda_basic_execution" {
  role       = aws_iam_role.api_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Scoped to just uploading CSVs into this bucket - it never reads from S3 or
# touches DynamoDB directly, that's the processor Lambda's job.
data "aws_iam_policy_document" "api_lambda_permissions" {
  statement {
    sid       = "UploadStudentCsv"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }
}

resource "aws_iam_role_policy" "api_lambda_permissions" {
  name   = "${var.project_name}-api-lambda-permissions"
  role   = aws_iam_role.api_lambda_exec.id
  policy = data.aws_iam_policy_document.api_lambda_permissions.json
}
