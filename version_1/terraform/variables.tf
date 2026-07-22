variable "project_name" {
  description = "Prefix used for naming every resource in this project"
  type        = string
  default     = "student-enrollment"
}

variable "aws_region" {
  description = "value"
  type        = string
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Python runtime version for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "container_port" {
  description = "Port Streamlit listens on inside the container"
  type        = number
  default     = 8501
}

variable "container_cpu" {
  description = "Fargate task CPU units (256 = .25 vCPU, the Fargate minimum)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate task memory in MB (512 is the minimum paired with 256 CPU)"
  type        = number
  default     = 512
}