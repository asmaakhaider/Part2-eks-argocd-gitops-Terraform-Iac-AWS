
##########################
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
#############################################
# MODULE Cert-Manager depuis helm
#############################################
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.2"  # adapte la version si besoin

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }

  depends_on = [
    aws_eks_access_entry.asmaa,
    aws_eks_access_policy_association.asmaa_admin
  ]
}
##############################################
#   créer un ClusterIssuer via Helm 
############################
resource "helm_release" "clusterissuer" {
  name             = "cert-clusterissuer"
  namespace        = "cert-manager"
  chart            = "${path.module}/../../charts/clusterissuer"

  depends_on = [
    helm_release.cert_manager
  ]
}


