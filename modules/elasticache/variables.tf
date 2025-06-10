variable "private_subnet_a_id" {
  description = "ID of the private subnet A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet B"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "redis_cluster_id" {
  description = "The cluster ID for the Redis instance"
  type        = string
  default     = "basket-redis"
}

variable "redis_engine" {
  description = "The cache engine used for ElastiCache"
  type        = string
  default     = "redis"
}

variable "redis_node_type" {
  description = "The instance type for Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "The number of cache nodes in the Redis cluster"
  type        = number
  default     = 1
}

variable "redis_parameter_group_name" {
  description = "The parameter group name for Redis"
  type        = string
  default     = "default.redis7"
}

variable "eks_cluster_endpoint" {
  description = "eks cluster endpoint"
  type        = string
}
variable "eks_cluster_ca" {
  description = "eks cluster endpoint"
  type        = string
}
