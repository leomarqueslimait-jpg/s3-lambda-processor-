resource "aws_dynamodb_table" "students" {
  name         = "${var.project_name}-students"
  billing_mode = "PAY_PER_REQUEST" # no capacity planning needed at this scale
  hash_key     = "student_id"

  attribute {
    name = "student_id"
    type = "S"
  }
}
