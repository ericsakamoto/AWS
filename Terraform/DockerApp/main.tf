########################################
########################################
###                                  ###
###  Docker Application with Ansible ###
###                                  ###
########################################
########################################

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

resource "aws_instance" "skmt_docker_app" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.vpc.outputs.skmt_public_subnet_ansible
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.skmt_sg_ansible]
  key_name               = "esakamoto-aws3-us-key"
  associate_public_ip_address = true
  iam_instance_profile = "SKMT-EC2-Role"
  user_data = <<-EOF
      #!/bin/bash

  EOF
  
  tags = {
    Name = "SKMT-Docker"
    SKMT-SystemManager = true
  }
}

resource "local_file" "ip" {
    content  = aws_instance.skmt_docker_app.public_ip
    filename = "ip.txt"
    # provisioner "file" {
    #     source      = "ip.txt"
    #     destination = "/home/ec2-user/environment/AWS/Terraform/DockerApp/ip.txt"
    # } 
}

resource "null_resource" "nullremote1" {
    depends_on = [local_file.ip]  
    provisioner "local-exec" {
        command = "ansible-playbook site.yaml"
    }
}



