# Terraform provisions the repo, but building and pushing the image is a
# manual step (no local-exec here - keep image builds out of the state file).
# After `terraform apply`:
#
#   aws ecr get-login-password --region <aws_region> \
#     | docker login --username AWS --password-stdin <ecr_repository_url>
#   docker build -t <ecr_repository_url>:latest ../form
#   docker push <ecr_repository_url>:latest
#   aws ecs update-service --cluster <ecs_cluster_name> \
#     --service <ecs_service_name> --force-new-deployment
#
# (values for the placeholders above are in `terraform output`)
resource "aws_ecr_repository" "form_app" {
  name                 = "${var.project_name}-form"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
