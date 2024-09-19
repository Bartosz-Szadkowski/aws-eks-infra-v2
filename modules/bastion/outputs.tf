# output "bastion_public_ips" {
#   description = "Public IPs of the bastion hosts"
#   value       = [for instance in aws_instance.bastion : instance.public_ip]
# }

output "bastion_security_group_id" {
  description = "The security group ID of the bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "instance_role_arn" {
  value = aws_iam_role.instance_role.arn
}