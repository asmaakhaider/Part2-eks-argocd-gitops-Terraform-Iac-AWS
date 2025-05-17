# RDS Configuration
variable "vpc_id" {
  type        = string
  description = "ID du VPC"
}

variable "namespace" {
  type        = string
  description = "Préfixe commun pour nommer les ressources"
}


variable "instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}


# variable "db_port" {
#   description = "Port de l'instance RDS"
#   type        = number
#   default     = 5432
# }

variable "database_name" {
  description = "Nom de la base de données RDS"
  type        = string
  default     = "eshopdb"
}

variable "database_user" {
  description = "Nom d'utilisateur de la base de données RDS"
  type        = string
  default     = "devops"
}

variable "database_password" {
  description = "Mot de passe de la base de données RDS"
  type        = string
  sensitive   = true
  default = "eshopdevops2025"
}


variable "private_subnet_a_id" {
  description = "ID of the private subnet A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet B"
  type        = string
}


variable "rds_s3_bucket_backup_name" {
  default = "eshop-postgres-db-backup-bucket"
}

# variable "eks_security_group_id" {
#   description = "ID du Security Group des Noeuds EKS"
#   type        = string
# }

variable "bastion_sg_id" {
  description = "ID du security group bastion"
  type        = string
}


variable "security_group_id" {
  description = "ID du Security Group RDS crée dans le moduele security_group"
  type        = string
}


variable "ingress_rds_security_group" {
  description = "Port d'entrée autorisé vers RDS (ex: 5432 pour PostgreSQL)"
  type        = number
}

variable "egress_rds_security_group" {
  description = "Port de sortie autorisé pour RDS (souvent 0 = tous)"
  type        = number
}

variable "eks_security_group_id" {
  description = "Security Group ID utilisé par les nodes EKS pour accéder à la base de données"
  type        = string
}

