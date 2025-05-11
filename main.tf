# appel du module networking
module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "eks" {
  source              = "./modules/eks"
  eks_version         = var.eks_version
  namespace           = var.namespace
  vpc_id              = module.networking.vpc_id
  private_subnet_a_id = module.networking.private_subnet_a_id
  private_subnet_b_id = module.networking.private_subnet_b_id
  

}
