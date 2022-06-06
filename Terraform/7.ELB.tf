#ALB 생성
resource "aws_alb" "alb" {
  name            = "dev-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb-cherry.id}"]
  subnets         = [
    "${aws_subnet.sub-a.id}",
    "${aws_subnet.sub-d.id}"
  ]
  
# access-log는 S3버켓에 저장하도록 지정
  access_logs {
    bucket  = "${aws_s3_bucket.mason88.id}"
    prefix  = "dev-alb"
    enabled = true
  }
  tags = {
    Name = "dev-alb"
  }
}
#lifecycle은 ALB가 재생성되면 새로운 ALB를 생성 후 이전 ALB 삭제되도록 Downtime 없도록 함
#  lifecycle { create_before_destroy = true }
#}
#ALB Target Group 생성
resource "aws_alb_target_group" "dev-cherry" {
  name     = "dev-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.dev.id}"

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = { Name = "dev-target-group" }
}
#ALB Target Group static생성(request 전용)
#resource "aws_alb_target_group" "static" {
#  name     = "static-target-group"
#  port     = 80
#  protocol = "HTTP"
#  vpc_id   = "${aws_vpc.dev.id}"

#  health_check {
#    interval            = 30
#    path                = "/ping"
#    healthy_threshold   = 3
#    unhealthy_threshold = 3
#  }

#  tags { Name = "Static Target Group" }
#}

resource "aws_alb_target_group_attachment" "attach-cherry" {
  target_group_arn = "${aws_alb_target_group.dev-cherry.arn}"
  target_id        = "${aws_instance.mason.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "attach-cherry1" {
  target_group_arn = "${aws_alb_target_group.dev-cherry.arn}"
  target_id        = "${aws_instance.lackhyun.id}"
  port             = 80
}
#resource "aws_alb_target_group_attachment" "static" {
#  target_group_arn = "${aws_alb_target_group.static.arn}"
#  target_id        = "${aws_instance.static.id}"
#  port             = 80
#}

#listener 설정
#data "aws_acm_certificate" "example_dot_com"   { 
#  domain   = "*.example.com."
#  statuses = ["ISSUED"]
#}

#resource "aws_alb_listener" "https" {
#  load_balancer_arn = "${aws_alb.frontend.arn}"
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "${data.aws_acm_certificate.example_dot_com.arn}"

#  default_action {
#    target_group_arn = "${aws_alb_target_group.frontend.arn}"
#    type             = "forward"
#  }
#}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.dev-cherry.arn}"
    type             = "forward"
  }
}

#ALB listener rule(static 설정)
#resource "aws_alb_listener_rule" "static" {
#  listener_arn = "${aws_alb_listener.https.arn}"
#  priority     = 100

#  action {
#    type             = "forward"
#    target_group_arn = "${aws_alb_target_group.static.arn}"
#  }

#  condition {
#    field  = "path-pattern"
#    values = ["/static/*"]
#  }
#
