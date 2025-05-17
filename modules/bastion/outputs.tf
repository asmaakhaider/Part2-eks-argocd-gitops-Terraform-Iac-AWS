output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
output "bastion_role_name" {
  value = aws_iam_role.bastion_role.name
}
