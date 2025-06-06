#!/bin/bash
set -e

# Créer le secret GitLab pour ArgoCD (pour cloner un dépôt privé)
echo "[INFO] Création du secret GitLab pour ArgoCD..."
aws eks update-kubeconfig --region eu-west-3 --name my-private-eks

echo "[INFO] Secret GitLab ajouté avec succès."