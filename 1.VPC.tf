## VPC 생성
resource "aws_vpc" "dev" {
  cidr_block                       = "172.32.0.0/16"
  instance_tenancy                 = "default"
  tags = {
    Name    = "DEV-VPC"
   }
}