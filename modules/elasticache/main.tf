resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redis-subnet-group"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id] # Use both subnets
}

resource "aws_security_group" "redis_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379 #Redis runs on port 6379 by default
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # Restrict access within the VPC
  }
}

# create redis for basket_api service
resource "aws_elasticache_cluster" "basket_redis" {
  cluster_id           = var.redis_cluster_id
  engine               = var.redis_engine
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = var.redis_parameter_group_name
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids   = [aws_security_group.redis_sg.id]
}
