variable "project_name" {
  description = "Prefix used for naming every resource in this project"
  type        = string
  default     = "student-enrollment-v2"
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

variable "tags" {
  description = "tags to apply to all resources"
  type = map(string)

}