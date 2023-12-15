data "aws_ami" "linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "test-server" {
  ami = data.aws_ami.linux.id
  instance_type = "t2.micro"
  key_name = "mason"

    root_block_device {
    volume_size = "20"
    volume_type = "gp3"
  }
  tags = {
    Name = "test-server"
  }
  
}