# appel du module networking
module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}
# appel du module eks
module "eks" {
  source              = "./modules/eks"
  eks_version         = var.eks_version
  namespace           = var.namespace
  vpc_id              = module.networking.vpc_id
  private_subnet_a_id = module.networking.private_subnet_a_id
  private_subnet_b_id = module.networking.private_subnet_b_id
  

  
}

#Appel module bastion
module "bastion" {
  source            = "./modules/bastion"
  vpc_id            = module.networking.vpc_id
  public_subnet_a_id  = module.networking.public_subnet_a_id
  eks_worker_sg_id = module.eks.eks_worker_sg_id
  bastion_sg_id = module.bastion.bastion_sg_id  # ou une autre source correcte
  eks_cluster_name  = module.eks.eks_cluster_name
  private_key_path  = "${path.module}/key-bastion.pem"
}


# appel du module ingress
module "ingress" {
  source        = "./modules/ingress"
  eks_cluster_name = module.eks.eks_cluster_name
  aws_region   = "eu-west-3" # ou utilisez une variable
  vpc_id       = module.networking.vpc_id
  eks_cluster_endpoint = module.eks.eks_cluster_endpoint
  eks_cluster_ca   = module.eks.eks_cluster_ca
  depends_on = [module.eks, module.bastion]
  
}


# Appel module rds
module "rds" {
  source              = "./modules/rds"
  namespace           = var.namespace
  vpc_id              = module.networking.vpc_id
  private_subnet_a_id = module.networking.private_subnet_a_id
  private_subnet_b_id = module.networking.private_subnet_b_id
  bastion_sg_id       = module.bastion.bastion_sg_id
  security_group_id   = module.rds.rds_sg_id
  ingress_rds_security_group = var.ingress_rds_security_group
  egress_rds_security_group  = var.egress_rds_security_group
  eks_security_group_id = module.eks.eks_worker_sg_id


}
# appel elasticache
module "elasticache" {
  source                     = "./modules/elasticache"
  vpc_cidr_block             = module.networking.vpc_cidr_block
  vpc_id                     = module.networking.vpc_id
  private_subnet_a_id        = module.networking.private_subnet_a_id
  private_subnet_b_id        = module.networking.private_subnet_b_id
}


