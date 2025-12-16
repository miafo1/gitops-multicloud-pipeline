# Infrastructure Teardown Guide

This guide provides step-by-step instructions to safely destroy all AWS infrastructure created by this project and verify that all costs have been eliminated.

## ⚠️ Important Warning

**This will permanently delete all resources.** Make sure you have:
- Backed up any important data
- Documented any configurations you want to keep
- Verified you're in the correct AWS account

## Prerequisites

- AWS CLI configured with admin access
- Terraform installed
- Access to the GitHub repository

## Teardown Steps

### Step 1: Delete ArgoCD (if deployed)

```bash
# Delete ArgoCD Application
kubectl delete -f argocd/applications/gitops-app.yaml

# Uninstall ArgoCD
helm uninstall argocd -n argocd

# Delete namespace
kubectl delete namespace argocd
```

### Step 2: Delete Application Deployments

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/manifests/

# Verify all pods are deleted
kubectl get pods --all-namespaces
```

### Step 3: Destroy AWS Infrastructure

```bash
# Navigate to live environment
cd infra/live/dev/aws

# Review what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy -auto-approve

# Verify destruction
aws eks list-clusters --region us-east-1
aws ecr describe-repositories --region us-east-1
```

### Step 4: Destroy Bootstrap Resources

```bash
# Navigate to bootstrap directory
cd ../../../bootstrap

# Destroy S3 and DynamoDB
terraform destroy -auto-approve
```

### Step 5: Clean Up IAM Resources

```bash
# Detach policy from role
aws iam detach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsECRPolicy

# Delete role
aws iam delete-role --role-name GitHubActionsRole

# Delete policy
aws iam delete-policy \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsECRPolicy

# Delete OIDC provider
aws iam delete-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
```

### Step 6: Verify Complete Teardown

Run these commands to verify all resources are deleted:

```bash
# Check EKS clusters
aws eks list-clusters --region us-east-1

# Check ECR repositories
aws ecr describe-repositories --region us-east-1

# Check VPCs (look for custom VPCs)
aws ec2 describe-vpcs --region us-east-1

# Check S3 buckets
aws s3 ls | grep gitops

# Check DynamoDB tables
aws dynamodb list-tables --region us-east-1 | grep gitops

# Check IAM roles
aws iam list-roles | grep GitHubActions

# Check NAT Gateways (these cost money!)
aws ec2 describe-nat-gateways --region us-east-1

# Check Elastic IPs
aws ec2 describe-addresses --region us-east-1
```

## Cost Verification Checklist

- [ ] No EKS clusters running
- [ ] No ECR repositories exist
- [ ] No custom VPCs (only default VPC should remain)
- [ ] No NAT Gateways
- [ ] No Elastic Load Balancers
- [ ] No S3 buckets with "gitops" in the name
- [ ] No DynamoDB tables with "gitops" in the name
- [ ] No Elastic IPs allocated
- [ ] No EC2 instances running

## Expected Timeline

- **ArgoCD deletion**: ~1 minute
- **Kubernetes resources**: ~2 minutes
- **EKS cluster destruction**: ~10-15 minutes
- **VPC/networking cleanup**: ~5 minutes
- **Total**: ~20-25 minutes

## Troubleshooting

### "Resource still in use" errors

If Terraform fails to destroy resources:

1. Manually delete dependent resources first:
   ```bash
   # Delete all pods
   kubectl delete pods --all --all-namespaces
   
   # Delete all services
   kubectl delete svc --all --all-namespaces
   ```

2. Wait 5 minutes for AWS to clean up

3. Retry `terraform destroy`

### VPC won't delete

```bash
# List all network interfaces
aws ec2 describe-network-interfaces --region us-east-1

# Delete stuck network interfaces
aws ec2 delete-network-interface --network-interface-id eni-xxxxx
```

### S3 bucket not empty

```bash
# Empty the bucket first
aws s3 rm s3://BUCKET_NAME --recursive

# Then destroy with Terraform
terraform destroy
```

## Final Verification

After 24 hours, check your AWS billing dashboard:
1. Go to AWS Console → Billing Dashboard
2. Verify no charges for:
   - EKS
   - EC2
   - NAT Gateway
   - Data Transfer
   - ECR

## Re-deployment

To redeploy the infrastructure later, simply run:
```bash
cd infra/bootstrap
terraform init && terraform apply

cd ../live/dev/aws
terraform init && terraform apply
```
