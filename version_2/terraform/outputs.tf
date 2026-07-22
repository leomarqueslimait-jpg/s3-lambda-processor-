output "bucket_name" {
  description = "Set this as BUCKET_NAME when running the API Lambda locally"
  value       = aws_s3_bucket.uploads.id
}

output "table_name" {
  value = aws_dynamodb_table.students.name
}

output "lambda_function_name" {
  value = aws_lambda_function.student_processor.function_name
}

output "api_invoke_url" {
  description = "Paste this into API_URL in static/index.html"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/submit"
}
