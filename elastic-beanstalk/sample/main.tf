
resource "aws_elastic_beanstalk_application" "example" {
  name        = "example-application"
  description = "A simple Elastic Beanstalk application"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name                = "example-environment"
  application         = aws_elastic_beanstalk_application.example.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.4 running Node.js 16"  # Update for your environment
}

output "elastic_beanstalk_url" {
  value = aws_elastic_beanstalk_environment.example.endpoint_url
}
