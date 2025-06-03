variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "eshopContainers"
  type        = string
}


variable "eks_version" {
  type        = string
  default     =  "1.29"


}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "ingress_rds_security_group" {
  description = "Port d'entrée autorisé vers RDS (ex: 5432 pour PostgreSQL)"
  type        = number
  default     = 5432
}

variable "egress_rds_security_group" {
  description = "Port de sortie autorisé pour RDS (souvent 0 = tous)"
  type        = number
  default     = 0
}


