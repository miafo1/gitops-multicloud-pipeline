# Multi-Cloud GitOps Pipeline (AWS Primary)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29-blue)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange)](https://argoproj.github.io/cd/)

## 🚀 Project Overview

A **production-grade GitOps pipeline** demonstrating modern DevOps practices for deploying microservices to Kubernetes. This project showcases:

- **Infrastructure as Code** (Terraform)
- **GitOps** continuous delivery (ArgoCD)
- **CI/CD automation** (GitHub Actions)
- **Multi-cloud architecture** (AWS real, Azure/GCP simulated)
- **Container orchestration** (Kubernetes/EKS)
- **Cost optimization** strategies

**Built for**: DevOps portfolio, technical interviews, and learning production-grade cloud infrastructure.

## 🎯 Problem Solved

Traditional deployment processes are manual, error-prone, and lack auditability. This project solves these problems by implementing:

1. **Declarative Infrastructure**: All infrastructure defined as code
2. **Automated Deployments**: Code changes automatically deployed to production
3. **Version Control**: Complete audit trail of all changes
4. **Self-Healing**: Automatic recovery from configuration drift
5. **Multi-Cloud Ready**: Architecture supports multiple cloud providers

## 🏗 Architecture

```
Developer → GitHub → GitHub Actions → ECR → ArgoCD → EKS Cluster
                                              ↓
                                        Auto-Sync from Git
```

**Full architecture details**: See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

### Key Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Infrastructure** | Terraform | Provision AWS resources (VPC, EKS, ECR) |
| **CI Pipeline** | GitHub Actions | Build Docker images, push to ECR |
| **CD Pipeline** | ArgoCD | GitOps-based deployment to Kubernetes |
| **Orchestration** | AWS EKS | Kubernetes cluster management |
| **Application** | Python/Flask | Sample microservice |
| **Multi-Cloud** | Terraform Modules | Simulated Azure AKS & GCP GKE |

## 📂 Project Structure

```
gitops-multicloud-pipeline/
├── .github/workflows/     # CI/CD pipelines
├── app/                   # Sample microservice
│   ├── src/              # Python Flask application
│   ├── Dockerfile        # Container definition
│   └── requirements.txt  # Dependencies
├── infra/                # Infrastructure as Code
│   ├── modules/          # Reusable Terraform modules
│   │   ├── aws/         # Real AWS infrastructure
│   │   ├── azure-simulated/  # Simulated Azure
│   │   └── gcp-simulated/    # Simulated GCP
│   ├── live/            # Environment configurations
│   └── bootstrap/       # Terraform state backend
├── k8s/                  # Kubernetes manifests
│   └── manifests/       # Deployment, Service configs
├── argocd/              # ArgoCD configuration
│   └── applications/    # Application definitions
├── scripts/             # Automation scripts
└── docs/                # Documentation
```

## 🛠 Tech Stack

### Core Technologies
- **Cloud**: AWS (EKS, VPC, ECR, IAM, S3, CloudWatch)
- **IaC**: Terraform 1.5+
- **Containers**: Docker
- **Orchestration**: Kubernetes 1.29
- **GitOps**: ArgoCD
- **CI/CD**: GitHub Actions
- **Languages**: Python 3.9, HCL, YAML, Bash

### AWS Services Used
- **EKS**: Managed Kubernetes cluster
- **ECR**: Container image registry
- **VPC**: Network isolation
- **IAM**: Access management (OIDC for GitHub Actions)
- **S3**: Terraform state storage
- **DynamoDB**: State locking
- **CloudWatch**: Logging and monitoring

## 📋 Prerequisites

- AWS Account (Free Tier compatible, but EKS costs ~$0.10/hour)
- AWS CLI configured
- Terraform >= 1.5.0
- kubectl
- Helm 3.x
- Docker
- Git

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/miafo1/gitops-multicloud-pipeline.git
cd gitops-multicloud-pipeline
```

### 2. Bootstrap Infrastructure

```bash
cd infra/bootstrap
terraform init && terraform apply
```

### 3. Deploy AWS Infrastructure

```bash
cd ../live/dev/aws
terraform init && terraform apply
```

**Duration**: ~15-20 minutes

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --name gitops-cluster-dev --region us-east-1
kubectl get nodes
```

### 5. Deploy ArgoCD

```bash
chmod +x scripts/deploy-argocd.sh
./scripts/deploy-argocd.sh
```

### 6. Setup CI/CD

Follow [`docs/AWS_IAM_SETUP.md`](docs/AWS_IAM_SETUP.md) to configure GitHub Actions.

**Complete deployment guide**: [`docs/DEPLOYMENT_GUIDE.md`](docs/DEPLOYMENT_GUIDE.md)

## 💰 Cost Optimization

### Monthly Cost Breakdown (if left running)

| Component | Cost/Month |
|-----------|------------|
| EKS Control Plane | $73 |
| EC2 (t3.medium Spot) | $15-30 |
| NAT Gateway | $32 |
| Data Transfer | $5-10 |
| **Total** | **~$125-145** |

### Optimization Strategies

✅ **Spot Instances**: 60-90% savings on compute  
✅ **Single NAT Gateway**: $32/month savings vs multi-AZ  
✅ **Right-sized instances**: t3.medium (minimum for EKS)  
✅ **Destroy when not in use**: Follow [`docs/TEARDOWN.md`](docs/TEARDOWN.md)

## 🔄 GitOps Workflow

1. **Developer** commits code to `main` branch
2. **GitHub Actions** builds Docker image and pushes to ECR
3. **GitHub Actions** updates Kubernetes manifest with new image tag
4. **ArgoCD** detects manifest change in Git
5. **ArgoCD** syncs changes to EKS cluster
6. **Kubernetes** performs rolling update
7. **Application** updated with zero downtime

## 🔒 Security Features

- **IAM Least Privilege**: Minimal permissions for all roles
- **OIDC Authentication**: No hardcoded AWS credentials
- **Non-root Containers**: Security best practice
- **Image Scanning**: Enabled in ECR
- **Private Subnets**: EKS nodes not publicly accessible
- **Secrets Management**: Kubernetes Secrets (not in Git)

## 📊 Monitoring & Observability

- **CloudWatch Logs**: EKS cluster and application logs
- **Kubernetes Probes**: Liveness and readiness checks
- **ArgoCD Dashboard**: Application health and sync status
- **Resource Metrics**: CPU/Memory usage tracking

## 🌐 Multi-Cloud Simulation

This project demonstrates multi-cloud architecture knowledge without incurring costs for Azure/GCP:

- **AWS EKS**: Real deployment (primary)
- **Azure AKS**: Simulated via Terraform (no cost)
- **GCP GKE**: Simulated via Terraform (no cost)

The simulated modules use `local_file` resources to create mock kubeconfig files, proving the architecture can support multiple clouds.

## 📚 Documentation

- **[Architecture](docs/ARCHITECTURE.md)**: Detailed technical architecture
- **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)**: Step-by-step deployment
- **[AWS IAM Setup](docs/AWS_IAM_SETUP.md)**: GitHub Actions authentication
- **[Teardown Guide](docs/TEARDOWN.md)**: Infrastructure destruction
- **[Alpine Setup](ALPINE_SETUP.md)**: Tool installation for Alpine Linux

## 🧪 Testing the Pipeline

### Make a Code Change

```bash
# Edit app/src/app.py - change version
git add app/src/app.py
git commit -m "Update app version"
git push origin main
```

### Watch the Magic

1. **GitHub Actions**: Check Actions tab for build status
2. **ArgoCD UI**: Watch sync status at `https://localhost:8080`
3. **Kubernetes**: `kubectl get pods -w` to see rolling update

### Verify Deployment

```bash
kubectl port-forward svc/gitops-app-service 8000:80
curl http://localhost:8000
```

## 🗑️ Cleanup

**IMPORTANT**: To avoid ongoing AWS charges, destroy all infrastructure:

```bash
# Follow complete teardown guide
cat docs/TEARDOWN.md

# Quick teardown
cd infra/live/dev/aws
terraform destroy -auto-approve

cd ../../bootstrap
terraform destroy -auto-approve
```

## 🎓 Learning Outcomes

This project demonstrates proficiency in:

- ✅ Kubernetes cluster management
- ✅ Infrastructure as Code (Terraform)
- ✅ GitOps principles and ArgoCD
- ✅ CI/CD pipeline design
- ✅ Container orchestration
- ✅ AWS cloud services
- ✅ Security best practices
- ✅ Cost optimization strategies
- ✅ Multi-cloud architecture

## 🤝 Contributing

This is a portfolio project, but suggestions are welcome! Please open an issue to discuss proposed changes.

## 📄 License

MIT License - See LICENSE file for details

## 👤 Author

**CHEUSSOPKENG MIAFO ARNAULD PARFAIT**

- GitHub: [@miafo1](https://github.com/miafo1)
- Project: [gitops-multicloud-pipeline](https://github.com/miafo1/gitops-multicloud-pipeline)

## 🙏 Acknowledgments

- HashiCorp for Terraform
- CNCF for Kubernetes and ArgoCD
- AWS for cloud infrastructure
- GitHub for CI/CD platform

---

**⭐ If this project helped you learn DevOps/GitOps, please star the repository!**
