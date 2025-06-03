#!/bin/bash
set -e

echo "[INFO] Déploiement de ArgoCD via Helm..."

aws eks update-kubeconfig --region eu-west-3 --name my-private-eks

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace

echo "[INFO] ArgoCD installé avec succès."
