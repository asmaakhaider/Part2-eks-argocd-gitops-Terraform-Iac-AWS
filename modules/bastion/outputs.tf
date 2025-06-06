output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
output "bastion_role_name" {
  value = aws_iam_role.bastion_role.name

}
output "bastion_public_ip" {
  description = "Adresse IP publique de la bastion host"
  value       = aws_instance.bastion.public_ip
}


output "bastion_admin_policy_arn" {
  value = aws_eks_access_policy_association.bastion_admin.id
}


