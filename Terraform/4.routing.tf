## IGW 라우팅 테이블 생성
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.dev.id}"
tags = {
    Name = "DEV-IGW"
  }
  }
resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.dev.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
tags = {
    Name = "DEV-ROUTE-PUB"
  }
}
## NAT Gateway 생성
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.gw"]
}
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.sub-a.id}"
  tags = {
    Name = "gw NAT"
  }
  depends_on = ["aws_internet_gateway.gw"]
}  
resource "aws_route_table" "nat" {
  vpc_id = "${aws_vpc.dev.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }
tags = {
    Name = "DEV-NAT"
  }
}
## 서브넷에 라우팅 연결
 resource "aws_route_table_association" "A" {
  subnet_id      = "${aws_subnet.sub-a.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "C" {
  subnet_id      = "${aws_subnet.sub-c.id}"
  route_table_id = "${aws_route_table.nat.id}"
}

resource "aws_route_table_association" "B" {
  subnet_id      = "${aws_subnet.sub-b.id}"
  route_table_id = "${aws_route_table.nat.id}"
}

resource "aws_route_table_association" "D" {
  subnet_id      = "${aws_subnet.sub-d.id}"
  route_table_id = "${aws_route_table.route.id}"
}

