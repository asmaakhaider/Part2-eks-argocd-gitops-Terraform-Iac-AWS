###########################
# IAM Access Entry
###########################

resource "aws_eks_access_entry" "asmaa" {
  cluster_name  = var.eks_cluster_name
  principal_arn = "arn:aws:iam::183631326752:user/asmaa"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "asmaa_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_eks_access_entry.asmaa.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

###########################
# nginx-ingress Controller
###########################

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.replicaCount"
    value = 1
  }

  depends_on = [
    aws_eks_access_entry.asmaa,
    aws_eks_access_policy_association.asmaa_admin
  ]
}
