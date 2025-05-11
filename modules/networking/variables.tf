# environnement de déploiement
variable "namespace" {
  type = string
}
# VPC
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "proget_vpc"
}


# Bloc CIDR pour le premier sous-réseau public dans la zone de disponibilité A.
variable "cidr_public_subnet_a" {
  description = "Bloc CIDR pour le sous-réseau public A (utilisé dans la zone de disponibilité A)"
  default     = "10.0.128.0/20"
}


# Bloc CIDR pour le deuxième sous-réseau public dans la zone de disponibilité B.
variable "cidr_public_subnet_b" {
  description = "Bloc CIDR pour le sous-réseau public B (utilisé dans la zone de disponibilité B)"
  default     = "10.0.144.0/20"
}


# Bloc CIDR pour le premier sous-réseau privé dans la zone de disponibilité A.
variable "cidr_private_subnet_a" {
  description = "Bloc CIDR pour le sous-réseau privé A (utilisé dans la zone de disponibilité A)"
  default     = "10.0.0.0/19"
}


# Bloc CIDR pour le deuxième sous-réseau privé dans la zone de disponibilité B.
variable "cidr_private_subnet_b" {
  description = "Bloc CIDR pour le sous-réseau privé B (utilisé dans la zone de disponibilité B)"
  default     = "10.0.32.0/19"
}

# Availability zones
variable "az_a" {
  description = "First availability zone"
  default     = "eu-west-3a"
}

variable "az_b" {
  description = "Second availability zone"
  default     = "eu-west-3b"
}


