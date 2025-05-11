# Exporter l'ID du VPC
output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.proget_vpc.id
}

output "vpc_cidr_block" {
  description = "Le CIDR bloc du vpc"
  value       = aws_vpc.proget_vpc.cidr_block
}
output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_subnet_b.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}


