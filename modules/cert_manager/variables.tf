variable "eks_cluster_name" {
  type        = string
  description = "Nom du cluster EKS"
}

variable "cluster_issuer_name" {
  description = "Nom du ClusterIssuer pour cert-manager"
  type        = string
}

