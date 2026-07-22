resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}

resource "aws_cloudwatch_log_group" "form_app" {
  name              = "/ecs/${var.project_name}-form-app"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "form_app" {
  family                   = "${var.project_name}-form-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  # Terraform only defines the task - it doesn't build/push the image. See
  # the commands documented in ecr.tf; until an image is pushed, the first
  # deployment will fail to start (nothing at the ":latest" tag yet).
  container_definitions = jsonencode([
    {
      name      = "form-app"
      image     = "${aws_ecr_repository.form_app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BUCKET_NAME"
          value = aws_s3_bucket.uploads.id
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.form_app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "form-app"
        }
      }
    }
  ])
}

# desired_count = 1, no load balancer - the task's public IP can change on
# restart. Look it up after deploying with:
#   aws ecs describe-tasks --cluster <ecs_cluster_name> \
#     --tasks $(aws ecs list-tasks --cluster <ecs_cluster_name> \
#     --service-name <ecs_service_name> --query 'taskArns[0]' --output text)
resource "aws_ecs_service" "form_app" {
  name            = "${var.project_name}-form-app"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.form_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.form_app.id]
    assign_public_ip = true
  }
}
