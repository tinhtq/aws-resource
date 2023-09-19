resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default
  health_check {
    protocol = "HTTP"
    path = "/index.html"
    healthy_threshold = 3
    interval = 6
  }
}
resource "aws_lb_target_group_attachment" "tg_attachment" {
count = length(aws_instance.webserver)
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver[count.index].id
  port             = 80
}
