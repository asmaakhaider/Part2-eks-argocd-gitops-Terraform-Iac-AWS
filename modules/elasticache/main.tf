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
###############################################
# relier Redis avec mon bascket-api 
######################################
provider "kubernetes" {
  alias                  = "local"
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.eks_cluster_ca)
  config_path            = "~/.kube/config"
}

resource "kubernetes_secret" "basket_redis_connection" {
  provider = kubernetes.local
  metadata {
    name      = "basket-redis-connection"
    namespace = "eshop-oncontainer"
  }

  data = {
    REDIS_CONNECTION_STRING = base64encode(
      "redis://${aws_elasticache_cluster.basket_redis.cache_nodes[0].address}:6379"
    )
  }

  type = "Opaque"
}

