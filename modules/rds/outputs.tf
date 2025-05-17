# Récupérer l'endpoint de l'instance RDS

output "postgresql_instance" {
  value = aws_db_instance.postgresql
}
output "rds_endpoint" {
  value = aws_db_instance.postgresql.endpoint
}

output "rds_address" {
  value = aws_db_instance.postgresql.address
}

output "rds_port" {
  description = "Port de l'instance RDS PostgreSQL"
  value       = aws_db_instance.postgresql.port
}

output "rds_database_name" {
  value = aws_db_instance.postgresql.db_name
}

output "rds_database_user" {
  value = aws_db_instance.postgresql.username
}

output "rds_database_password" {
  value = aws_db_instance.postgresql.password
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

