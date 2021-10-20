## EC2 "GW" 생성
resource "aws_instance" "gw" {
  ami             = "ami-08c64544f5cfcddd0"
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = "${aws_subnet.sub-a.id}"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  associate_public_ip_address = true
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    tags = {
        Name = "GW"
    }
}
## EC2 "mason" 생성
resource "aws_instance" "mason" {
  ami             = "ami-08c64544f5cfcddd0"
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = "${aws_subnet.sub-c.id}"
  vpc_security_group_ids = [aws_security_group.ec2.id]
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    tags = {
        Name = "Mason"
    }
}
## EC2 "lackhyun" 생성
resource "aws_instance" "lackhyun" {
  ami             = "ami-08c64544f5cfcddd0"
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = "${aws_subnet.sub-b.id}"
  vpc_security_group_ids = [aws_security_group.ec2.id]
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    tags = {
        Name = "lackhyun"
    }
}
## EC2 "cherry" 생성
resource "aws_instance" "cherry" {
  ami             = "ami-08c64544f5cfcddd0"
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = "${aws_subnet.sub-a.id}"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  associate_public_ip_address = true
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    tags = {
        Name = "cherry"
    }
}