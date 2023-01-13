## AWS 프로바이더 정의
provider "aws" {
  # shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "ap-northeast-2"
}
