resource "aws_s3_bucket" "mason88" {
  bucket = "mason-s3"
  acl = "private"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::600734575887:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::mason-s3/dev-alb/AWSLogs/*"
    }
  ]
}
  POLICY
 tags = {
    Name        = "dev-s3"
    Environment = "Dev"
  }
 # lifecycle_rule {
 #   id      = "log_lifecycle"
 #   prefix  = "dev-alb"
 #   enabled = true

 #   transition {
 #     days          = 30
 #     storage_class = "GLACIER"
 #   }

 #   expiration {
 #     days = 90
 #   }
 # }

 # lifecycle {
 #   prevent_destroy = true
 # }
}