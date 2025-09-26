output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = aws_instance.web.instance_type
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.web.private_ip
}

