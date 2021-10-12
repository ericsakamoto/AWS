terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../VPC/terraform.tfstate"
  }
}

resource "aws_instance" "skmt_ansible_server" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.vpc.outputs.skmt_public_subnet_ansible //aws_subnet.skmt_public_subnet_ansible.id
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.skmt_sg_ansible] //[aws_security_group.skmt_sg_ansible.id]
  key_name               = "esakamoto-aws3-us-key"
  associate_public_ip_address = true
  iam_instance_profile = "SKMT-EC2-Role"
  user_data = <<-EOF
      #!/bin/bash
      sudo su - ec2-user
      sudo amazon-linux-extras -y install epel
      sudo amazon-linux-extras -y install ansible2
  EOF

  tags = {
    Name = var.instance_name
    SKMT-SystemManager = true
  }
}

resource "aws_instance" "skmt_ansible_client" {
  count                  = 2
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.vpc.outputs.skmt_public_subnet_ansible //aws_subnet.skmt_public_subnet_ansible.id
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.skmt_sg_ansible] //[aws_security_group.skmt_sg_ansible.id]
  key_name               = "esakamoto-aws3-us-key"
  associate_public_ip_address = tr
  iam_instance_profile = "SKMT-EC2-Role"
  user_data = <<-EOF
      #!/bin/bash

  EOF

  tags = {
    Name = "SKMT-Client-${count.index}"
    SKMT-SystemManager = true
  }
}

