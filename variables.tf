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
