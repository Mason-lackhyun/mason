
resource "aws_subnet" "sub-a" {
  vpc_id = "${aws_vpc.dev.id}"
  cidr_block = "172.32.0.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "DEV-PUB-A"
  }
 }
resource "aws_subnet" "sub-c" {
  vpc_id = "${aws_vpc.dev.id}"
  cidr_block = "172.32.10.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "DEV-PRI-C"
  }
}