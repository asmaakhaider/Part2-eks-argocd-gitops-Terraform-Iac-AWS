output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
output "bastion_ip" {
  value = module.bastion.bastion_public_ip
}
