data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# No load balancer for this demo - the task gets a public IP directly, so
# this security group has to allow inbound traffic straight to the container.
resource "aws_security_group" "form_app" {
  name        = "${var.project_name}-form-app"
  description = "Allow inbound Streamlit traffic and all outbound"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Streamlit"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
