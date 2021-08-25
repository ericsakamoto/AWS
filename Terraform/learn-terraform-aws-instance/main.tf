terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "sa-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f8243a5175208e08"
  instance_type = "t2.micro"

  tags = {
    Name = "SKMT-EC2-Server"
  }
}