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
 resource "aws_route_table_association" "A" {
  subnet_id      = "${aws_subnet.sub-a.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "C" {
  subnet_id      = "${aws_subnet.sub-b.id}"
  route_table_id = "${aws_route_table.route.id}"
}