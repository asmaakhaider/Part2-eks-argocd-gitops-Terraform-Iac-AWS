###########################
# IAM Access Entry
###########################

#resource "aws_eks_access_entry" "asmaa" {
 # cluster_name  = var.eks_cluster_name
 # principal_arn = "arn:aws:iam::183631326752:user/asmaa"
 # type          = "STANDARD"
#}

#resource "aws_eks_access_policy_association" "asmaa_admin" {
 # cluster_name  = var.eks_cluster_name
 # principal_arn = aws_eks_access_entry.asmaa.principal_arn
 # policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  #access_scope {
   # type = "cluster"
  #}
#}

###########################
# nginx-ingress Controller
###########################

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.replicaCount"
    value = 1
  }

 # depends_on = [
  #  aws_eks_access_entry.asmaa,
   # aws_eks_access_policy_association.asmaa_admin
  #]
}

######################################
# Ingress pour ArgoCD
##################################

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "cert-manager.io/cluster-issuer"               = var.cluster_issuer_name
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = ["argocd.khaider.asmaa.cloudns.ch"]
      secret_name = "argocd-tls"  # Ce sera généré par cert-manager
    }

    rule {
      host = "argocd.khaider.asmaa.cloudns.ch"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}
