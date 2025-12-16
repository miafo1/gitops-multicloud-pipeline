resource "aws_ecr_repository" "gitops_app" {
  name                 = "gitops-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "gitops-pipeline"
    Environment = "dev"
    Terraform   = "true"
  }
}

output "repository_url" {
  value       = aws_ecr_repository.gitops_app.repository_url
  description = "ECR repository URL"
}

output "repository_name" {
  value       = aws_ecr_repository.gitops_app.name
  description = "ECR repository name"
}
