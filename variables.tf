variable "aws_region" {
  type        = string
  description = "default region for the aws account"
}

variable "arbitrary_terraform_state_bucket" {
  type        = string
  description = "Bucket for managing the terraform state files"
}

variable "iam_role_name" {
  type        = string
  description = "IAM Role name"
}

variable "iam_policy_name" {
  type        = string
  description = "IAM Policy name"
}

variable "lambda_name" {
  type        = string
  description = "Lambda Function name"
}