################################################################################
# Role IAM pour le Cluster EKS
###############################################################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role-VPC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

################################################################################
#  Cluster EKS dans les sous-réseaux privés
###############################################################################
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-private-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = [var.private_subnet_a_id, var.private_subnet_b_id]
    endpoint_private_access = true # Accès privé au cluster
    endpoint_public_access  = true
    public_access_cidrs     = ["176.148.244.129/32"]
    #public_access_cidrs     = var.allowed_ips # Restriction sur les IP autorisées
    # Add security groups
    security_group_ids = [aws_security_group.eks_control_plane_sg.id, aws_security_group.eks_worker_sg.id]
  }
  #Activer le mode API ou API_AND_CONFIG_MAP dans le cluster 
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]



  tags = {
    Name = "${var.namespace}-my-alb-tf"
  }

}
################################################################################
#  Role IAM pour les Worker Nodes
###############################################################################
# Worklow: IAM Role => Instance Profile => Attaché aux EC2 ou Nodegroup Instance Profile
# avec les policies nécessaires.

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "autoscaler" {
  name = "eshop-eks-autoscaler-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })

} #Tous ces droits sont indispensables pour que le Cluster Autoscaler fonctionne correctement.

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}


resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.eks_node_role.name
}

# On ne peut pas directement associer un rôle à une EC2, on doit d'abord créer un Instance Profile contenant ce rôle
# et rattacher le role du worker crée plus haut à l'instance profile
resource "aws_iam_instance_profile" "eks_worker_profile" {
  depends_on = [aws_iam_role.eks_node_role]
  name       = "eshop-eks-worker-new-profile"
  role       = aws_iam_role.eks_node_role.name
}


################################################################################
# Groupe de nœuds pour EKS
###############################################################################
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eshop_node_groups"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_a_id, var.private_subnet_b_id]

  scaling_config {
    desired_size = var.eks_desired_worker_node
    max_size     = var.eks_max_worker_node
    min_size     = var.eks_min_worker_node
  }


  instance_types = var.instance_type # Type d’instance pour les nodes

  tags = {
    Name = "eks_nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
  ]

}


#######################################################
# Creer groupe de sécurité pour Master Nodes and workers nodes
#######################################################

resource "aws_security_group" "eks_control_plane_sg" {
  vpc_id = var.vpc_id
  name   = "eks-control-plane-sg"

  # Autoriser uniquement les Worker Nodes à parler au Control Plane (via aws_security_group_rule)

  # Autoriser les administrateurs (kubectl) à interagir avec l'API (RESTREINT)
  ingress {
    description = "Allow admin access to EKS API"
    from_port   = var.ingress_Control_plane_and_WkNodes_port_SG
    to_port     = var.ingress_Control_plane_and_WkNodes_port_SG
    protocol    = "tcp"
   
  }

  # Autorise tout le trafic sortant
  egress {
    from_port   = var.egress_Control_plane_port_and_WkNodes_SG
    to_port     = var.egress_Control_plane_port_and_WkNodes_SG
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_EKS_SG
  }

  tags = {
    Name = "EKS-ControlPlane-SG"
  }
}


# Séparer la règle pour autoriser les Worker Nodes à communiquer avec le Control Plane
resource "aws_security_group_rule" "allow_workers_to_control_plane" {
  type                     = "ingress"
  from_port                = var.ingress_Control_plane_and_WkNodes_port_SG
  to_port                  = var.ingress_Control_plane_and_WkNodes_port_SG
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane_sg.id
  source_security_group_id = aws_security_group.eks_worker_sg.id
}


# Worker Nodes Security groups
resource "aws_security_group" "eks_worker_sg" {
  vpc_id = var.vpc_id
  name   = "eks-worker-sg"

  # Autorise le trafic entre les Worker Nodes (ex: pour les pods)
  ingress {
    description = "Allow inter-node communication"
    from_port   = var.ingress_Worker_Nodes_SG[0]
    to_port     = var.ingress_Worker_Nodes_SG[1]
    protocol    = "tcp"
    self        = true #signifie que ce SG autorise le trafic entre ses propres membres (Worker Nodes).
  }


  # Autorise le trafic HTTP et HTTPS pour les applications Kubernetes
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = var.ingress_Control_plane_and_WkNodes_port_SG
    to_port     = var.ingress_Control_plane_and_WkNodes_port_SG
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_EKS_SG # Ajuster selon les besoins
  }

  # Autorise tout le trafic sortant (ex: accès aux AWS Services)
  egress {
    from_port   = var.egress_Control_plane_port_and_WkNodes_SG
    to_port     = var.egress_Control_plane_port_and_WkNodes_SG
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_EKS_SG
  }

  tags = {
    Name = "EKS-Worker-SG"
  }
}

# Séparer la règle pour la communication Control Plane -> Worker Nodes
resource "aws_security_group_rule" "allow_cp_to_worker" {
  type                     = "ingress"
  from_port                = var.ingress_Worker_Nodes_Security_rules[0]
  to_port                  = var.ingress_Worker_Nodes_Security_rules[1]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_sg.id
  source_security_group_id = aws_security_group.eks_control_plane_sg.id
}

# Séparer la règle pour la communication Worker Nodes -> Control Plane
resource "aws_security_group_rule" "allow_worker_to_cp" {
  type                     = "ingress"
  from_port                = var.ingress_Worker_Nodes_Security_rules[0]
  to_port                  = var.ingress_Worker_Nodes_Security_rules[1]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane_sg.id
  source_security_group_id = aws_security_group.eks_worker_sg.id
}

#######################################################
# politiques IAM pour ingress controller
#######################################################
resource "aws_iam_policy" "ingress_controller_policy" {
  name        = "eshop-eks-ingress-controller-policy"
  description = "Permissions for ingress controller to manage AWS resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets"
        ],
        Resource = "*"
      }
    ]
  })
}
# attacher cette politique au rôle des worker nodes 
resource "aws_iam_role_policy_attachment" "ingress_controller" {
  policy_arn = aws_iam_policy.ingress_controller_policy.arn
  role       = aws_iam_role.eks_node_role.name
}










