output "skmt_vpc_ansible" {
  description = "ID of the VPC"
  value       = aws_vpc.skmt_vpc_ansible.id
}

output "skmt_public_subnet_ansible" {
  description = "ID of the public subnet"
  value       = aws_subnet.skmt_public_subnet_ansible.id
}

output "skmt_sg_ansible" {
  description = "ID of the security group"
  value       = aws_security_group.skmt_sg_ansible.id
}