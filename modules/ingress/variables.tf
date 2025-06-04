variable "eks_cluster_name" {
  type        = string
  description = "Nom du cluster EKS"
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
}
variable "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  type        = string
}

variable "eks_cluster_ca" {
  description = "Certificat du cluster EKS (CA Data)"
  type        = string
}


variable "cluster_issuer_name" {
  description = "Nom du cluster issuer à utiliser pour cert-manager"
  type        = string
}


