resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.0.0"  # Version stable


  create_namespace = true
  values = [file("${path.module}/values-argocd.yaml")]
}

##########################
# ArgoCD application deployment
##########################
# modules/argocd/main.tf
resource "helm_release" "argocd_applications" {
  name       = "argocd-applications"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "1.0.0"  # Version plus stable que 2.0.0

  values = [
    file("${path.module}/values.yaml")
  ]

  # Assurez-vous que ArgoCD est déjà installé
  depends_on = [helm_release.argocd]
}

