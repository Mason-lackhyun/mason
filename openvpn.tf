provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "ap-northeast-2"
}
locals {
    mason                 = "vpc-0f670b7cac5d2b309"
    mason_subnet_id       = "subnet-0edd159283ee4e12a" 
    VPN_security_group    = "sg-0c5ab0f80be462c5d"     # VPNSG
    De_security_group     = "sg-051cf47da17b2436b"     # Default
    amzl2_ami_id          = "ami-08c64544f5cfcddd0"
}
resource "aws_security_group" "masonvpn-ec2" {
    name        = "masonvpn-ec2"
    description = "masonvpn-ec2"
    vpc_id      = local.mason
    ingress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["172.16.0.0/12"]
        description = "mason"
    }
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "masonvpn" {
  ami             = local.amzl2_ami_id
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = local.mason_subnet_id
  vpc_security_group_ids = [
      local.VPN_security_group, local.De_security_group,
       aws_security_group.masonvpn-ec2.id
    ]
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    tags = {
        Name = "masonvpn"
    }
}