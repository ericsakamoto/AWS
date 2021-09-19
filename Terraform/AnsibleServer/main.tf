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
  availability_zone = "sa-east-1a"

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
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_2_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "skmt_sg_rule_3_ansible" {
  security_group_id = aws_security_group.skmt_sg_ansible.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "skmt_ansible_server" {
  ami                    = "ami-09b9b17384f68fd7c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.skmt_public_subnet_ansible.id
  vpc_security_group_ids = [aws_security_group.skmt_sg_ansible.id]
  key_name               = "esakamoto-aws3-sp-key2"
  associate_public_ip_address = true
  iam_instance_profile = "SKMT-EC2-Role"
  user_data = <<-EOF
      #!/bin/bash
      sudo su - ec2-user
      sudo amazon-linux-extras -y install epel
      sudo yum -y install ansible
  EOF

  tags = {
    Name = var.instance_name
    SKMT-SystemManager = true
  }
}

