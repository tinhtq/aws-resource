
resource "aws_codecommit_repository" "test" {
  repository_name = var.repository_name
  description     = "The repository for static website"
  default_branch = var.branch
  tags = {
    Environment = "test"
  }
}

output "repository_clone_http" {
  value = aws_codecommit_repository.test.clone_url_http
}

variable "repository_name" {
  default = "MyTestRepo"
}

variable "branch" {
  default = "main"
}