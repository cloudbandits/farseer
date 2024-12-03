output "bastion_instance_ids" {
  description = "IDs of Bastion instances"
  value       = aws_instance.bastion[*].id
}

output "frontend_instance_ids" {
  description = "IDs of Frontend instances"
  value       = aws_instance.frontend[*].id
}

output "backend_instance_ids" {
  description = "IDs of Backend instances"
  value       = aws_instance.backend[*].id
}

output "bastion_security_group_id" {
  description = "ID of Bastion security group"
  value       = aws_security_group.bastion_sg.id
}

output "frontend_security_group_id" {
  description = "ID of Frontend security group"
  value       = aws_security_group.frontend_sg.id
}

output "backend_security_group_id" {
  description = "ID of Backend security group"
  value       = aws_security_group.backend_sg.id
}