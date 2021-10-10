resource "aws_internet_gateway" "DEV-gateway" {
  vpc_id = "DEV-VPC"
tags = {
    Name = "DEV-IGW"
  }
  }


resource "aws_route_table" "DEV-ROUTE-PUB" {
  vpc_id = "DEV-VPC"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "DEV-IGW"
  }
tags = {
    Name = "DEV-ROUTE-PUB"
  }
}


 resource "aws_route_table_association" "DEV-PUB-ROUTE-A" {
  subnet_id      = "DEV-PUB-A"
  route_table_id = "DEV-ROUTE-PUB"
}

resource "aws_route_table_association" "DEV-PUB-ROUTE-C" {
  subnet_id      = "DEV-PUB-C"
  route_table_id = "DEV-ROUTE-PUB"
} 
