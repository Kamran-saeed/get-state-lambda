output "lambda_function_arn" {
  description = "Lambda Funciton ARN"
  value       = aws_lambda_function.demicon_get_state_lambda.arn
}

output "iam_role_arn" {
  description = "IAM Role ARN of Lambda Function"
  value       = aws_iam_role.demicon_get_state_lambda_role.arn
}