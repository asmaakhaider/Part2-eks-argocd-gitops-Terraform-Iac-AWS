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
  bastion_sg_id = module.bastion.bastion_sg_id  
  eks_cluster_name  = module.eks.eks_cluster_name
  private_key_path  = "${path.module}/key-bastion.pem"
  depends_on = [module.eks]
}


# appel du module ingress
module "ingress" {
  source        = "./modules/ingress"
 
  
 # depends_on = [module.eks]

  
}
# apple du module argocd

module "argocd" {
  source = "./modules/argocd"
  #depends_on = [module.eks]
 
}


# apple du module cert_manager

module "cert_manager" {
  source = "./modules/cert_manager"
  eks_cluster_name = module.eks.eks_cluster_name
  cluster_issuer_name    = "letsencrypt-asmaa"
 # depends_on = [module.eks]
  

}


# apple du module prometheus_grafana
module "prometheus_grafana" {
  source = "./modules/prometheus_grafana"
  

}

# apple du module velero
module "velero" {
  source = "./modules/velero"
  

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
  eks_cluster_endpoint  = module.eks.eks_cluster_endpoint
  eks_cluster_ca  = module.eks.eks_cluster_ca

 


}
# appel elasticache
module "elasticache" {
  source                     = "./modules/elasticache"
  vpc_cidr_block             = module.networking.vpc_cidr_block
  vpc_id                     = module.networking.vpc_id
  private_subnet_a_id        = module.networking.private_subnet_a_id
  private_subnet_b_id        = module.networking.private_subnet_b_id
  eks_cluster_endpoint  = module.eks.eks_cluster_endpoint
  eks_cluster_ca  = module.eks.eks_cluster_ca
  #depends_on = [module.eks]

}



