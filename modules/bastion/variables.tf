variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "Projet_AWS"
  type        = string
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}
variable "public_subnet_a_id" {
  type        = string
  description = "The ID of the first public subnet"
}

variable "instance_type" {
  description = "Type d'instance pour le bastion host"
  type        = string
  default     = "t2.micro"
}


variable "key_name" {
  description = "nom de la clef du serveur pour nous connecter en ssh sur celui-ci"
  type        = string
  default     = "key-bastion"

}
variable "EC2_min_size" {
  description = "Taille minimale du groupe Auto Scaling"
  type        = number
  default     = 1
}

variable "EC2_desired_bastion" {
  description = "Capacité désirée du Bastion Host"
  type        = number
  default     = 1
}

variable "EC2_max_size" {
  description = "Taille maximale du groupe Auto Scaling"
  type        = number
  default     = 2
}

variable "bastion_sg_id" {
  description = "ID du groupe de sécurité des Worker Nodes EKS"
  type        = string
}
variable "eks_worker_sg_id" {
  description = "Security group ID of EKS worker nodes"
  type        = string
}
variable "eks_cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

