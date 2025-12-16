# Multi-Cloud GitOps Pipeline (AWS Primary)

## 🚀 Project Overview
This project demonstrates a **Production-Grade GitOps Pipeline** deploying microservices to **AWS EKS** while simulating multi-cloud deployments for **Azure AKS** and **GCP GKE**.

It uses **Terraform** for Infrastructure as Code (IaC), **ArgoCD** for GitOps-based continuous delivery, and **GitHub Actions** for Continuous Integration.

## 🏗 Architecture
The pipeline follows a GitOps pull-based architecture.

```text
+-----------------------------------------------------------------------------------+
|                                 GitHub (VCS)                                      |
|  +-----------------+       +-------------------+       +-----------------------+  |
|  |  App Repository |       |  Infra Repository |       |   GitOps Repository   |  |
|  |   (Source Code) |       |    (Terraform)    |       | (Helm/K8s Manifests)  |  |
|  +--------+--------+       +---------+---------+       +-----------+-----------+  |
|           |                          |                             ^              |
|           v                          v                             |              |
|  +--------+--------+       +---------+---------+                   |              |
|  | GitHub Actions  |       | Terraform Cloud / |                   |              |
|  |      (CI)       |       |   Local CLI       |                   |              |
|  +--------+--------+       +---------+---------+                   |              |
|           |                          |                             |              |
|           | Build & Push             | Provision                   | Sync         |
|           v                          v                             |              |
|  +--------+--------+       +---------+---------+       +-----------+-----------+  |
|  |   Amazon ECR    |       |   AWS Cloud       |       |      ArgoCD           |  |
|  | (Container Reg) |       | (EKS, VPC, IAM)   |       | (Running on EKS)      |  |
|  +-----------------+       +-------------------+       +-----------+-----------+  |
|                                                                    |              |
|                                                                    v              |
|                                                            +-------+-------+      |
|                                                            |  EKS Cluster  |      |
|                                                            | (Real Deploy) |      |
|                                                            +---------------+      |
|                                                                                   |
|                                                            +---------------+      |
|                                                            |  AKS (Sim)    |      |
|                                                            |  (No Deploy)  |      |
|                                                            +---------------+      |
|                                                                                   |
|                                                            +---------------+      |
|                                                            |  GKE (Sim)    |      |
|                                                            |  (No Deploy)  |      |
|                                                            +---------------+      |
+-----------------------------------------------------------------------------------+
```

## 📂 Project Structure
```bash
gitops-multicloud-pipeline/
├── .github/workflows/   # CI/CD Workflows
├── app/                 # Application Source Code (Microservice)
├── infra/               # Terraform IaC
│   ├── modules/         # Reusable modules (AWS Real, Azure/GCP Sim)
│   └── live/            # Environment configurations
├── k8s/                 # Kubernetes Manifests & Helm Charts
└── argocd/              # ArgoCD App of Apps / Configuration
```

## 🛠 Tech Stack
- **Cloud**: AWS (EKS, VPC, IAM, ECR, S3)
- **Simulated Cloud**: Azure (AKS), Google Cloud (GKE)
- **IaC**: Terraform
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI**: GitHub Actions
- **CD**: ArgoCD
- **Languages**: HCL, YAML, Python/Node.js, Bash

## 📋 Prerequisites
- AWS Account (Free Tier friendly, but EKS incurs ~$0.10/hour cost)
- AWS CLI configured
- Terraform >= 1.5.0
- kubectl
- Docker
