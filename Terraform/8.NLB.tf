resource "aws_lb" "test" {
  name               = "nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.sub-a.id}","${aws_subnet.sub-d.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "prod"
    name = "nlb-mason"
  }
}
