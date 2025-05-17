################################################################################
# Outputs pour eks, Load Balancer,
################################################################################
output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.eks_cluster.name
}

output "eks_node_group_name" {
  description = "Nom du groupe de nœuds"
  value       = aws_eks_node_group.eks_nodes.node_group_name
}

output "eks_security_group_id" {
  description = "Id du groupe de sécurité du Nodegroup EKS"
  value       = aws_security_group.eks_worker_sg.id
}


output "eks_cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_worker_sg_id" {
  value = aws_security_group.eks_worker_sg.id
}

