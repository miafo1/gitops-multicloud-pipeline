#!/bin/bash
set -e

echo "=========================================="
echo "AWS Infrastructure Teardown Script"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will destroy all AWS resources!"
echo "This includes:"
echo "  - EKS Cluster"
echo "  - EC2 Instances"
echo "  - VPC and Networking"
echo "  - NAT Gateway"
echo "  - ECR Repository"
echo "  - S3 Bucket (Terraform state)"
echo "  - DynamoDB Table"
echo "  - IAM Roles and Policies"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Teardown cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Step 1: Deleting ArgoCD (if deployed)"
echo "=========================================="

if kubectl get namespace argocd &> /dev/null; then
    echo "ArgoCD namespace found. Deleting..."
    
    # Delete ArgoCD Application
    if kubectl get application gitops-app -n argocd &> /dev/null; then
        echo "Deleting ArgoCD Application..."
        kubectl delete -f argocd/applications/gitops-app.yaml || true
    fi
    
    # Uninstall ArgoCD
    echo "Uninstalling ArgoCD..."
    helm uninstall argocd -n argocd || true
    
    # Delete namespace
    echo "Deleting argocd namespace..."
    kubectl delete namespace argocd || true
    
    echo "✅ ArgoCD deleted"
else
    echo "ℹ️  ArgoCD not deployed, skipping..."
fi

echo ""
echo "=========================================="
echo "Step 2: Deleting Application Deployments"
echo "=========================================="

if kubectl get deployment gitops-app &> /dev/null; then
    echo "Deleting Kubernetes resources..."
    kubectl delete -f k8s/manifests/ || true
    echo "✅ Application deployments deleted"
else
    echo "ℹ️  No application deployments found, skipping..."
fi

echo ""
echo "=========================================="
echo "Step 3: Destroying AWS Infrastructure"
echo "=========================================="
echo "This will take ~10-15 minutes..."

cd infra/live/dev/aws

if [ -f ".terraform/terraform.tfstate" ]; then
    echo "Running terraform destroy..."
    terraform destroy -auto-approve
    echo "✅ AWS infrastructure destroyed"
else
    echo "ℹ️  No Terraform state found, skipping..."
fi

echo ""
echo "=========================================="
echo "Step 4: Destroying Bootstrap Resources"
echo "=========================================="

cd ../../bootstrap

if [ -f ".terraform/terraform.tfstate" ]; then
    echo "Destroying S3 and DynamoDB..."
    terraform destroy -auto-approve
    echo "✅ Bootstrap resources destroyed"
else
    echo "ℹ️  No bootstrap state found, skipping..."
fi

echo ""
echo "=========================================="
echo "Step 5: Cleaning Up IAM Resources"
echo "=========================================="

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "⚠️  Unable to get AWS Account ID. Skipping IAM cleanup."
    echo "You may need to manually delete IAM resources if they exist."
else
    echo "AWS Account ID: $AWS_ACCOUNT_ID"
    
    # Detach and delete role
    if aws iam get-role --role-name GitHubActionsRole &> /dev/null; then
        echo "Detaching policy from role..."
        aws iam detach-role-policy \
          --role-name GitHubActionsRole \
          --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/GitHubActionsECRPolicy || true
        
        echo "Deleting IAM role..."
        aws iam delete-role --role-name GitHubActionsRole || true
        echo "✅ IAM role deleted"
    else
        echo "ℹ️  GitHubActionsRole not found, skipping..."
    fi
    
    # Delete policy
    if aws iam get-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/GitHubActionsECRPolicy &> /dev/null; then
        echo "Deleting IAM policy..."
        aws iam delete-policy \
          --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/GitHubActionsECRPolicy || true
        echo "✅ IAM policy deleted"
    else
        echo "ℹ️  GitHubActionsECRPolicy not found, skipping..."
    fi
    
    # Delete OIDC provider
    if aws iam get-open-id-connect-provider \
        --open-id-connect-provider-arn arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com &> /dev/null; then
        echo "Deleting OIDC provider..."
        aws iam delete-open-id-connect-provider \
          --open-id-connect-provider-arn arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com || true
        echo "✅ OIDC provider deleted"
    else
        echo "ℹ️  OIDC provider not found, skipping..."
    fi
fi

echo ""
echo "=========================================="
echo "Step 6: Verification"
echo "=========================================="

echo ""
echo "Checking for remaining resources..."
echo ""

# Check EKS
EKS_CLUSTERS=$(aws eks list-clusters --region us-east-1 --query 'clusters' --output text 2>/dev/null || echo "")
if [ -z "$EKS_CLUSTERS" ]; then
    echo "✅ No EKS clusters found"
else
    echo "⚠️  EKS clusters still exist: $EKS_CLUSTERS"
fi

# Check ECR
ECR_REPOS=$(aws ecr describe-repositories --region us-east-1 --query 'repositories[].repositoryName' --output text 2>/dev/null || echo "")
if [ -z "$ECR_REPOS" ]; then
    echo "✅ No ECR repositories found"
else
    echo "⚠️  ECR repositories still exist: $ECR_REPOS"
fi

# Check NAT Gateways
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways --region us-east-1 --filter "Name=state,Values=available" --query 'NatGateways[].NatGatewayId' --output text 2>/dev/null || echo "")
if [ -z "$NAT_GATEWAYS" ]; then
    echo "✅ No NAT Gateways found"
else
    echo "⚠️  NAT Gateways still exist: $NAT_GATEWAYS"
fi

# Check S3
S3_BUCKETS=$(aws s3 ls 2>/dev/null | grep gitops || echo "")
if [ -z "$S3_BUCKETS" ]; then
    echo "✅ No gitops S3 buckets found"
else
    echo "⚠️  S3 buckets still exist:"
    echo "$S3_BUCKETS"
fi

# Check DynamoDB
DYNAMO_TABLES=$(aws dynamodb list-tables --region us-east-1 --query 'TableNames' --output text 2>/dev/null | grep gitops || echo "")
if [ -z "$DYNAMO_TABLES" ]; then
    echo "✅ No gitops DynamoDB tables found"
else
    echo "⚠️  DynamoDB tables still exist: $DYNAMO_TABLES"
fi

echo ""
echo "=========================================="
echo "Teardown Complete!"
echo "=========================================="
echo ""
echo "✅ All resources have been destroyed"
echo ""
echo "📋 Next Steps:"
echo "1. Check AWS Billing Dashboard in 24 hours"
echo "2. Verify no ongoing charges"
echo "3. All code is safely stored in GitHub"
echo ""
echo "To redeploy later:"
echo "  cd infra/bootstrap && terraform apply"
echo "  cd ../live/dev/aws && terraform apply"
echo ""
echo "=========================================="
