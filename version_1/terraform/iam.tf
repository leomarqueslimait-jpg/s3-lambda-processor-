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

# --- Fargate task roles ---

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution role: lets ECS pull the image from ECR and ship logs to
# CloudWatch. Distinct from the task role below, which is what app.py's
# own boto3 client assumes at runtime.
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.project_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role: scoped to just uploading CSVs into this bucket, same scoping
# as the processor Lambda's permissions above.
resource "aws_iam_role" "ecs_task" {
  name               = "${var.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_permissions" {
  statement {
    sid       = "UploadStudentCsv"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_permissions" {
  name   = "${var.project_name}-ecs-task-permissions"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_permissions.json
}
