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
  region  = "sa-east-1"
}

resource "aws_vpc" "skmt_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "skmt_vpc"
  }
}

resource "aws_internet_gateway" "smkt_igw" {
  vpc_id = aws_vpc.skmt_vpc.id

  tags = {
    Name = "smkt_igw"
  }
}

resource "aws_subnet" "skmt_public_subnet" {
  vpc_id     = aws_vpc.skmt_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "skmt_public_subnet"
  }
}

resource "aws_route_table" "skmt_route_table" {
  vpc_id = aws_vpc.skmt_vpc.id

  tags = {
    Name = "skmt_route_table"
  }
}

resource "aws_route" "skmt_route_1" {
  route_table_id            = aws_route_table.skmt_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.smkt_igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.skmt_public_subnet.id
  route_table_id = aws_route_table.skmt_route_table.id
}

resource "aws_security_group" "skmt_sg" {
  name        = "skmt_sg"
  description = "Security Group for SKMT VPC"
  vpc_id      = aws_vpc.skmt_vpc.id

  tags = {
    Name = "skmt_sg"
  }
}

resource "aws_security_group_rule" "skmt_sg_rule_1" {
  security_group_id = aws_security_group.skmt_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_2" {
  security_group_id = aws_security_group.skmt_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_3" {
  security_group_id = aws_security_group.skmt_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "skmt_app_server" {
  ami                    = "ami-000aa26b054f3a383" //EC2 Docker private image
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.skmt_public_subnet.id
  vpc_security_group_ids = [aws_security_group.skmt_sg.id]
  key_name               = "esakamoto-aws4-sp-key"
  associate_public_ip_address = true
  user_data = <<-EOF
      #!/bin/bash
      sudo su - ec2-user
      sudo amazon-linux-extras -y install epel
      sudo yum -y install docker
      sudo yum -y install git
      sudo systemctl enable docker.service
      sudo systemctl start docker.service
      sudo usermod -a -G docker ec2-user
      id ec2-user
      newgrp docker
  EOF

  tags = {
    Name = var.instance_name
    SKMT-SystemManager = true
  }
}

