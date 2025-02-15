
output "iam_user_password" {
  value     = random_password.iam_user_password.result
  sensitive = true
}