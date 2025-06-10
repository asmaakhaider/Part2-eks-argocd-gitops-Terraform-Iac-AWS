variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "Projet_AWS"
  type        = string
}
variable "eks_version" {
  description = "version du cluster eks"

}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "private_subnet_a_id" {
  description = "ID of the private subnet A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet B"
  type        = string
}

variable "instance_type" {
  description = "Types d'instances pour les nodes EKS"
  type        = list(string)
  default     = ["t3a.medium"]
}

variable "eks_desired_worker_node" {
  default     = 4
  description = "eks_desired_worker_node"
}

variable "eks_min_worker_node" {
  default     = 2
  description = "eks_min_worker_node"
}

variable "eks_max_worker_node" {
  default     = 5
  description = "eks_max_worker_node"
}

variable "ingress_Control_plane_and_WkNodes_port_SG" {
  description = "Allow admin access to EKS API, HTTPS Access also"
  default     = 443
}

variable "egress_Control_plane_port_and_WkNodes_SG" {
  description = "autoriser les traffics sortants sur le control plane"
  default     = 0 # à modifier selon nos besoins si on ne veut pas autoriser tout le traffic.
}

variable "cidr_blocks_EKS_SG" {
  description = "definir les valeur des cidr blocs sur le control plane"
  default     = ["0.0.0.0/0"]
}

variable "ingress_Worker_Nodes_SG" {
  description = "Allow inter-node communication"
  default     = [0, 65535]
}

variable "ingress_Worker_Nodes_Security_rules" {
  description = "Create communication rules between control plane and worker node using the  default port 10250"
  default     = [10250, 10250] #creation du meme port sous forme de liste si les ports vont differer plus tard
}



# variable "bastion_public_ip" {
#   description = "adresse publique de bastion autorisée à accéder à notre eks"
#   type        = string
# }

# variable "allowed_ips" {
#   description = "adresses ips valides pour accéder au cluster"
# }
