################################################################################
# RDS
################################################################################

# Create RDS Subnet group
resource "aws_db_subnet_group" "RDS_subnet_grp" {

  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]
}


# Create RDS instance
resource "aws_db_instance" "postgresql" {
  identifier             = "postgresqldb" # Unique name for the RDS instance
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "13.20" #Choisir une version supportée á regarder sur AWS 
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_grp.name
  vpc_security_group_ids = [var.security_group_id]
  db_name                = var.database_name
  username               = var.database_user
  password               = var.database_password
  skip_final_snapshot    = true
  publicly_accessible    = false #RDS NE DOIT PAS être public !
  multi_az               = true

  tags = {
    Name = "${var.namespace}-rds-instance"
  }
}

################################
# Security group for RDS
##################################
resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
  name        = "rds-security-group"
  description = "SecurityGroup for RDS instance"

  # Autoriser l'accès des Noeuds EKS vers RDS (PostgreSQL)
  ingress {
    from_port       = var.ingress_rds_security_group
    to_port         = var.ingress_rds_security_group
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id] # Autorise le SG du Node Group EKS

  }

  #autoriser bastion à accéder à rds
  ingress {
    from_port       = var.ingress_rds_security_group # For RDS
    to_port         = var.ingress_rds_security_group
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
    # security_groups = [var.bastion_sg_id]
  }

  # Egress : Permet à RDS de répondre aux requêtes entrantes
  egress {
    from_port = var.egress_rds_security_group
    to_port   = var.egress_rds_security_group
    protocol  = "-1"
    # cidr_blocks = var.egress_cidr_rds_security_group
    security_groups = [var.eks_security_group_id]
    cidr_blocks     = ["0.0.0.0/0"] # Permet les réponses sortantes vers Internet/NAT
  }
  tags = {
    Name = "${var.namespace}-sg-database"
  }
}


##################################################################################
#  Création des Secrets Kubernetes pour lier mon application avec les DB de RDS
################################################################################
provider "kubernetes" {
  alias                  = "local"
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.eks_cluster_ca)
  config_path            = "~/.kube/config" # Utilise le kubeconfig local
}



# Crée le namespace
resource "kubernetes_namespace" "eshop" {
  provider = kubernetes.local
  metadata {
    name = "eshop-oncontainer"
  }



}

#########################################################
resource "kubernetes_secret" "eshop_db_connection_strings" {
  provider = kubernetes.local
  metadata {
    name      = "eshop-db-connection-strings"
    namespace = "eshop-oncontainer"
  }

  data = {
    ConnectionStrings__CatalogDB  = "Host=${aws_db_instance.postgresql.address};Port=5432;Database=catalog_db;Username=${var.database_user};Password=${var.database_password};"
    ConnectionStrings__OrderingDB = "Host=${aws_db_instance.postgresql.address};Port=5432;Database=ordering_db;Username=${var.database_user};Password=${var.database_password};"
    ConnectionStrings__IdentityDB = "Host=${aws_db_instance.postgresql.address};Port=5432;Database=identity_db;Username=${var.database_user};Password=${var.database_password};"
    ConnectionStrings__WebhooksDB = "Host=${aws_db_instance.postgresql.address};Port=5432;Database=webhooks_db;Username=${var.database_user};Password=${var.database_password};"
  }

  type = "Opaque"
}