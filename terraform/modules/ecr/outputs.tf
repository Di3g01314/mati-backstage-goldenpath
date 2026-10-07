output "repository_urls" { value = { for name, repository in aws_ecr_repository.application : name => repository.repository_url } }
