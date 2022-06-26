resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "terraform_test"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"

    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "terraform_public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.10.0/24"

    availability_zone = "ap-northeast-2b"

    tags = {
        Name = "terraform_private_subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "terraform_igw"
    }
}

resource "aws_eip" "nat_1" {
    vpc = true

    tags = {
        Name = "terraform_NAT"
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_nat_gateway" "nat_gateway1" {
    allocation_id = aws_eip.nat_1.id

    subnet_id = aws_subnet.public_subnet.id

    tags = {
        Name = "terraform-NAGW"
    }
}
## Public은 inner rule로 적용이 되었고
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    
    tags = {
        Name = "terraform-rt-public"
    }
}

resource "aws_route_table_association" "route_table_association_public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public.id
}
## Private는 외부로 코드로 작성해서 적용
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    
    tags = {
        Name = "terraform-rt-private"
    }
}

resource "aws_route_table_association" "route_table_association_private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_nat" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.ap-northeast-2.s3"

    tags = {
        Name = "terraform_S3"
    }
}

resource "aws_s3_bucket" "s3" {
    bucket = "devopsmason-terraform"
}

resource "aws_iam_user" "terraform_iam" {
    name ="terraform_iam"  
}

resource "aws_iam_group" "terraform_group" {
    name = "terraform_group"
}

resource "aws_iam_group_membership" "terraform_devops" {
    name = aws_iam_group.terraform_group.name
    users = [
        aws_iam_user.terraform_iam.name
    ]

    group = aws_iam_group.terraform_group.name
}

resource "aws_iam_role" "hello" {
  name               = "hello-iam-role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}
resource "aws_iam_role_policy" "hello_s3" {
  name   = "hello-s3-download"
  role   = aws_iam_role.hello.id
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AllowAppArtifactsReadAccess",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF

}
resource "aws_iam_instance_profile" "hello" {
  name = "hello-profile"
  role = aws_iam_role.hello.name
}
