
resource "aws_elastic_beanstalk_application" "example" {
  name        = "example-application"
  description = "A simple Elastic Beanstalk application"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name                = "example-environment"
  application         = aws_elastic_beanstalk_application.example.name
  solution_stack_name = var.solution_stack_name
  tier = var.tier
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = aws_iam_instance_profile.instance_profile.name
    }
}

output "elastic_beanstalk_url" {
  value = aws_elastic_beanstalk_environment.example.endpoint_url
}
