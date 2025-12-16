# AWS IAM Setup for GitHub Actions

This guide explains how to set up AWS IAM OIDC authentication for GitHub Actions to push Docker images to ECR.

## Prerequisites
- AWS CLI configured with admin access
- GitHub repository URL

## Step 1: Create OIDC Identity Provider

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## Step 2: Create IAM Policy for ECR Access

Create a file `ecr-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

Create the policy:
```bash
aws iam create-policy \
  --policy-name GitHubActionsECRPolicy \
  --policy-document file://ecr-policy.json
```

## Step 3: Create IAM Role for GitHub Actions

Create a file `trust-policy.json` (replace `YOUR_GITHUB_USERNAME` and `YOUR_REPO_NAME`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
        }
      }
    }
  ]
}
```

Create the role:
```bash
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json
```

Attach the policy:
```bash
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::YOUR_AWS_ACCOUNT_ID:policy/GitHubActionsECRPolicy
```

## Step 4: Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `AWS_ROLE_ARN`
5. Value: `arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubActionsRole`

## Step 5: Provision ECR Repository

```bash
cd infra/live/dev/aws
terraform apply
```

This will create the ECR repository defined in the Terraform module.

## Verification

Push a change to the `app/` directory and verify:
1. GitHub Actions workflow runs successfully
2. Docker image appears in ECR
3. Kubernetes manifest is updated with new image tag
