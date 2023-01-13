# resource "aws_s3_bucket" "mason88" {
#   bucket = "mason-s3"
#   acl = "private"
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Id": "Policy1634654583966",
#     "Statement": [
#         {
#             "Sid": "Stmt1634654580646",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "arn:aws:s3:::mason-s3/*"
#         }
#     ]
# }
#   POLICY
#  tags = {
#     Name        = "dev-s3"
#     Environment = "Dev"
#   }
#   lifecycle_rule {
#     id      = "log_lifecycle"
#     prefix  = "dev-alb"
#     enabled = true

#     transition {
#       days          = 30
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = 90
#     }
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }


# resource "aws_s3_bucket_public_access_block" "authority" {
#   bucket = aws_s3_bucket.mason88.id

#   block_public_acls   = true
#   block_public_policy = true
# }
