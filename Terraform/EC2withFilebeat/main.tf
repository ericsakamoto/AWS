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

resource "aws_vpc" "skmt_vpc_ec2_fbt" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "skmt_vpc_ec2_fbt"
  }
}

resource "aws_internet_gateway" "smkt_igw_ec2_fbt" {
  vpc_id = aws_vpc.skmt_vpc_ec2_fbt.id

  tags = {
    Name = "smkt_igw_ec2_fbt"
  }
}

resource "aws_subnet" "skmt_public_subnet_ec2_fbt" {
  vpc_id     = aws_vpc.skmt_vpc_ec2_fbt.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "skmt_public_subnet_ec2_fbt"
  }
}

resource "aws_route_table" "skmt_route_table_ec2_fbt" {
  vpc_id = aws_vpc.skmt_vpc_ec2_fbt.id

  tags = {
    Name = "skmt_route_table_ec2_fbt"
  }
}

resource "aws_route" "skmt_route_1_ec2_fbt" {
  route_table_id            = aws_route_table.skmt_route_table_ec2_fbt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.smkt_igw_ec2_fbt.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.skmt_public_subnet_ec2_fbt.id
  route_table_id = aws_route_table.skmt_route_table_ec2_fbt.id
}

resource "aws_security_group" "skmt_sg_ec2_fbt" {
  name        = "skmt_sg_ec2_fbt"
  description = "Security Group for SKMT VPC"
  vpc_id      = aws_vpc.skmt_vpc_ec2_fbt.id

  tags = {
    Name = "skmt_sg_ec2_fbt"
  }
}

resource "aws_security_group_rule" "skmt_sg_rule_1_ec2_fbt" {
  security_group_id = aws_security_group.skmt_sg_ec2_fbt.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_2_ec2_fbt" {
  security_group_id = aws_security_group.skmt_sg_ec2_fbt.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_3_ec2_fbt" {
  security_group_id = aws_security_group.skmt_sg_ec2_fbt.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "skmt_ec2_fbt_server" {
  ami                    = "ami-06a40c12e5bd9b028" //My Docker AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.skmt_public_subnet_ec2_fbt.id
  vpc_security_group_ids = [aws_security_group.skmt_sg_ec2_fbt.id]
  key_name               = "esakamoto-aws3-sp-key2"
  associate_public_ip_address = true
  iam_instance_profile = "SKMT-EC2-Role"
  user_data = <<-EOF
      #!/bin/bash

  EOF

  tags = {
    Name = var.ec2_fbt_instance_name
    SKMT-SystemManager = true
  }
}

