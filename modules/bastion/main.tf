# EC2  bastion host 
###################################################################""
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

###############################################################################
# Security Group pour Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-bastion_sg"
  }
}

#####################################################################################
# Bastion host avec  autoscaling Group
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_a_id
  vpc_security_group_ids     = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true
  key_name                    = var.key_name
  #Bastion EC2 doit disposer d'un rôle IAM aussi pour pouvoir interagir avec EKS!
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name


  #install kubectl, AWS ClI on Bastion

  user_data = <<-EOF
  #!/bin/bash

set -e

echo "[INFO] Mise à jour du système et installation des outils de base..."
yum update -y
yum install -y unzip curl bash-completion git jq

# Installer AWS CLI v2
echo "[INFO] Installation de l'AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Installer kubectl pour EKS 1.29.10 (amd64 - Amazon Linux 2)
echo "[INFO] Téléchargement de kubectl v1.29.10..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.10/2024-12-12/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.10/2024-12-12/bin/linux/amd64/kubectl.sha256

echo "[INFO] Vérification de l'intégrité du binaire kubectl..."
sha256sum -c kubectl.sha256

echo "[INFO] Installation de kubectl dans /usr/local/bin..."
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Installer Helm
echo "[INFO] Installation de Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version --short

# Configuration kubeconfig automatique (optionnel)
# export CLUSTER_NAME="my-private-eks"
# aws eks update-kubeconfig --name \$CLUSTER_NAME --region eu-west-3
echo "user_data exécuté avec succès."
EOF

  # Donner à Terraform le temps de laisser EC2 se lancer proprement
  timeouts {
    create = "10m"
  }
  tags = {
    Name = "${var.namespace}-bastion-host"
  }


}
resource "null_resource" "install_all" {
  depends_on = [aws_instance.bastion]
  triggers = {
    always_run = timestamp()
  }


  connection {
    type        = "ssh"
    host        = aws_instance.bastion.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    timeout     = "30m"
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/install-argocd.sh"
    destination = "/tmp/install-argocd.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Attente 60s pour laisser EC2 se stabiliser...'",
      "sleep 60",
      "chmod +x /tmp/install-argocd.sh",
      "bash /tmp/install-argocd.sh"
    ]
  }
}


#####################################
# Rôle IAM pour le Bastion
resource "aws_iam_role" "bastion_role" {
  name = "${var.namespace}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attache les policies nécessaires
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "bastion_eks_auth" {
  role       = aws_iam_role.bastion_role.name  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}



resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Instance Profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.namespace}-bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}




# Obtenir dynamiquement l'Account ID AWS
data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "bastion_access" {
  cluster_name = var.eks_cluster_name
  #bastion EC2 assume le rôle via un Instance Profile, donc l'ARN réel utilisé pour l'accès EKS est :
  #arn:aws:sts::<ACCOUNT_ID>:assumed-role/bastion-iam-role/<session-name>

  principal_arn = aws_iam_role.bastion_role.arn

  # principal_arn = "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/bastion-iam-role/*"
  type = "STANDARD"

  # depends_on = [aws_instance.bastion] # je retire ceci parce que l'instance bastion doit complètement etre crée avant d'appliquer l'access_entry si ceci est ajouté.
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_eks_access_entry.bastion_access.principal_arn
  #Cela donnera à notre Bastion les droits RBAC équivalents à system:masters dans Kubernetes, donc accès total au cluster via kubectl
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
    # namespaces = ["*"] # Accès à tous les namespaces
  }
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_get_token" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

