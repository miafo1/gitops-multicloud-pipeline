# Deployment Guide

Complete step-by-step guide to deploy the Multi-Cloud GitOps Pipeline.

## Prerequisites Checklist

### Required Tools
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.5.0
- [ ] kubectl
- [ ] Helm 3.x
- [ ] Docker
- [ ] Git

### AWS Requirements
- [ ] AWS Account with admin access
- [ ] AWS CLI configured (`aws configure`)
- [ ] Sufficient quota for:
  - 1 EKS cluster
  - 2 EC2 instances (t3.medium)
  - 1 NAT Gateway
  - 1 Application Load Balancer

### GitHub Requirements
- [ ] GitHub account
- [ ] Repository created: `gitops-multicloud-pipeline`
- [ ] Repository cloned locally

## Phase 1: Bootstrap Infrastructure

### 1.1 Create S3 Backend

```bash
cd infra/bootstrap
terraform init
terraform apply
```

**Output**: Note the `s3_bucket_name` - you'll need this next.

### 1.2 Update Backend Configuration

Edit `infra/live/dev/aws/main.tf`:
- Uncomment the `terraform` backend block
- Replace `REPLACE_WITH_YOUR_BUCKET_NAME` with the bucket name from step 1.1

## Phase 2: Provision AWS Infrastructure

### 2.1 Initialize and Apply

```bash
cd infra/live/dev/aws
terraform init
terraform apply
```

**Duration**: ~15-20 minutes

### 2.2 Configure kubectl

```bash
aws eks update-kubeconfig --name gitops-cluster-dev --region us-east-1
kubectl get nodes
```

**Expected output**: 1-2 nodes in `Ready` state

## Phase 3: Setup GitHub Actions (CI/CD)

### 3.1 Create IAM OIDC Provider

Follow instructions in `docs/AWS_IAM_SETUP.md`:

```bash
# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 3.2 Create IAM Role and Policy

See `docs/AWS_IAM_SETUP.md` for complete steps.

### 3.3 Add GitHub Secret

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add secret:
   - Name: `AWS_ROLE_ARN`
   - Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsRole`

## Phase 4: Deploy ArgoCD

### 4.1 Install ArgoCD

```bash
chmod +x scripts/deploy-argocd.sh
./scripts/deploy-argocd.sh
```

**Duration**: ~3-5 minutes

### 4.2 Access ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get password (printed by deploy script)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Open browser: `https://localhost:8080`
- Username: `admin`
- Password: (from above command)

### 4.3 Deploy Application to ArgoCD

```bash
kubectl apply -f argocd/applications/gitops-app.yaml
```

## Phase 5: Verify End-to-End Flow

### 5.1 Make a Code Change

```bash
# Edit app/src/app.py
# Change version from v1 to v2

git add app/src/app.py
git commit -m "Update app to v2"
git push origin main
```

### 5.2 Watch the Pipeline

1. **GitHub Actions**: Check Actions tab - should build and push image
2. **ArgoCD**: Watch ArgoCD UI - should detect change and sync
3. **Kubernetes**: `kubectl get pods -w` - should see rolling update

### 5.3 Test the Application

```bash
# Port forward to the service
kubectl port-forward svc/gitops-app-service 8000:80

# Test
curl http://localhost:8000
```

## Verification Checklist

- [ ] EKS cluster is running
- [ ] kubectl can connect to cluster
- [ ] ArgoCD is deployed and accessible
- [ ] GitHub Actions workflow runs successfully
- [ ] Docker image is pushed to ECR
- [ ] ArgoCD syncs application
- [ ] Application pods are running
- [ ] Application is accessible

## Common Issues

### Issue: "Kubernetes cluster unreachable"

**Solution**: Configure kubectl
```bash
aws eks update-kubeconfig --name gitops-cluster-dev --region us-east-1
```

### Issue: GitHub Actions fails with "AccessDenied"

**Solution**: Verify IAM role and OIDC provider are set up correctly
```bash
aws iam get-role --role-name GitHubActionsRole
```

### Issue: ArgoCD shows "Unknown" status

**Solution**: Check repository URL in `argocd/applications/gitops-app.yaml` matches your GitHub repo

### Issue: Pods stuck in "ImagePullBackOff"

**Solution**: Verify ECR repository exists and GitHub Actions pushed the image
```bash
aws ecr describe-images --repository-name gitops-app --region us-east-1
```

## Cost Management

**Expected Monthly Costs** (if left running):
- EKS Control Plane: ~$73/month
- EC2 Instances (t3.medium Spot): ~$15-30/month
- NAT Gateway: ~$32/month
- Data Transfer: ~$5-10/month
- **Total**: ~$125-145/month

**Cost Optimization**:
- Use Spot instances (already configured)
- Single NAT Gateway (already configured)
- Destroy infrastructure when not in use

## Next Steps

1. Explore ArgoCD UI
2. Make code changes and watch GitOps in action
3. Review CloudWatch logs
4. When done, follow `docs/TEARDOWN.md` to destroy infrastructure
