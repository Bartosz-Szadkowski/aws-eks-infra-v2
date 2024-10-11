resource "random_password" "argocd_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "argocd_secret" {
  name = "argocd-password"
}

resource "aws_secretsmanager_secret_version" "argocd_secret_version" {
  secret_id     = aws_secretsmanager_secret.argocd_secret.id
  secret_string = random_password.argocd_password.result
}