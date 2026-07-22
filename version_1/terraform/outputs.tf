output "bucket_name" {
  description = "Set this as BUCKET_NAME when running app.py"
  value       = aws_s3_bucket.uploads.id
}

output "table_name" {
  value = aws_dynamodb_table.students.name
}

output "lambda_function_name" {
  value = aws_lambda_function.student_processor.function_name
}

output "ecr_repository_url" {
  description = "Push the built image here (see build/push commands in ecr.tf)"
  value       = aws_ecr_repository.form_app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.form_app.name
}
