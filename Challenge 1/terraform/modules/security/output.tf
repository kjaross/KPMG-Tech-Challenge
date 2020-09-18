output "security_group_id_elb" {
  description = "The ID of the security group"
  value       = aws_security_group.elb_sg.id
}

output "security_group_id_web" {
  description = "The ID of the security group"
  value       = aws_security_group.web_sg.id
}
