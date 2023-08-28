
resource "aws_codecommit_repository" "test" {
  repository_name = "MyTestRepo"
  description     = "The repository for static website"
  tags = {
    Environment = "test"
  }
}

output "repository_clone_http" {
  value = aws_codecommit_repository.test.clone_url_http
}
