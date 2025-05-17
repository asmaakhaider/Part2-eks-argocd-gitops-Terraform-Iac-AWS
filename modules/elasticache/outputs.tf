output "redis_security_group_id" {
  description = "The security group ID for Redis"
  value       = aws_security_group.redis_sg.id
}
