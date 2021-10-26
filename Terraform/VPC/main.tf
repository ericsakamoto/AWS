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

resource "aws_vpc" "skmt_vpc_ansible" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "skmt_vpc_ansible"
  }
}

resource "aws_internet_gateway" "smkt_igw_ansible" {
  vpc_id = aws_vpc.skmt_vpc_ansible.id

  tags = {
    Name = "smkt_igw_ansible"
  }
}

resource "aws_subnet" "skmt_public_subnet_ansible" {
  vpc_id     = aws_vpc.skmt_vpc_ansible.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "skmt_public_subnet"
  }
}

resource "aws_route_table" "skmt_route_table_ansible" {
  vpc_id = aws_vpc.skmt_vpc_ansible.id

  tags = {
    Name = "skmt_route_table_ansible"
  }
}

resource "aws_route" "skmt_route_1_ansible" {
  route_table_id            = aws_route_table.skmt_route_table_ansible.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.smkt_igw_ansible.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.skmt_public_subnet_ansible.id
  route_table_id = aws_route_table.skmt_route_table_ansible.id
}

resource "aws_security_group" "skmt_sg_ansible" {
  name        = "skmt_sg_ansible"
  description = "Security Group for SKMT VPC"
  vpc_id      = aws_vpc.skmt_vpc_ansible.id

  tags = {
    Name = "skmt_sg_ansible"
  }
}

resource "aws_security_group_rule" "skmt_sg_rule_1_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.skmt_public_subnet_ansible.cidr_block]
}

resource "aws_security_group_rule" "skmt_sg_rule_2_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "ingress"
  from_port         = 1000
  to_port           = 1000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_3_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_4_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "ingress"
  from_port         = 7681
  to_port           = 7687
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
