## SG 생성 "ssh"
resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.dev.id}"
  tags = {
    Name    = "Ext to GW"
   }
  name = "DEV-SG"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## SG 생성 "ec2"
resource "aws_security_group" "ec2" {
  vpc_id = "${aws_vpc.dev.id}"
  tags = {
    Name    = "GW to EC2"
   }
  name = "GW to EC2"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.ssh.id}"]

  }
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}