#!/bin/bash
set -e

echo "=========================================="
echo "Deploying ArgoCD to EKS Cluster"
echo "=========================================="

# Add ArgoCD Helm repository
echo "Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create argocd namespace
echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "Installing ArgoCD..."
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=LoadBalancer \
  --wait

echo ""
echo "=========================================="
echo "ArgoCD Deployment Complete!"
echo "=========================================="

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get admin password
echo ""
echo "Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================="
echo "ArgoCD Access Information"
echo "=========================================="
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "To access ArgoCD UI:"
echo "1. Port forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Open browser: https://localhost:8080"
echo "3. Login with credentials above"
echo ""
echo "Or get the LoadBalancer URL:"
echo "kubectl get svc argocd-server -n argocd"
echo "=========================================="
