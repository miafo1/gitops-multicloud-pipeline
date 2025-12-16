# Architecture Documentation

## Overview

This project implements a production-grade GitOps pipeline using Kubernetes, ArgoCD, and GitHub Actions. It demonstrates multi-cloud capabilities by deploying to AWS EKS (real) while simulating Azure AKS and GCP GKE deployments.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            Developer Workflow                            │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ git push
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              GitHub Repository                           │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────────────┐  │
│  │  App Code    │    │  Terraform   │    │  K8s Manifests          │  │
│  │  (Python)    │    │  (IaC)       │    │  (GitOps Source)        │  │
│  └──────────────┘    └──────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
        ┌───────────────────────┐       ┌──────────────────────┐
        │   GitHub Actions      │       │   ArgoCD (GitOps)    │
        │   (CI Pipeline)       │       │   (CD Pipeline)      │
        └───────────────────────┘       └──────────────────────┘
                    │                               │
                    │ Build & Push                  │ Watch & Sync
                    ▼                               │
        ┌───────────────────────┐                  │
        │   Amazon ECR          │                  │
        │   (Container Registry)│                  │
        └───────────────────────┘                  │
                                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                   │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                         EKS Cluster                               │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐                 │  │
│  │  │   Pod 1    │  │   Pod 2    │  │  ArgoCD    │                 │  │
│  │  │  (App v1)  │  │  (App v1)  │  │  Server    │                 │  │
│  │  └────────────┘  └────────────┘  └────────────┘                 │  │
│  │                                                                   │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │              Service (LoadBalancer)                        │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │     VPC      │  │     ECR      │  │  CloudWatch  │                 │
│  │  (Networking)│  │  (Registry)  │  │   (Logs)     │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      Simulated Cloud Providers                          │
│  ┌──────────────────┐              ┌──────────────────┐                │
│  │  Azure AKS       │              │  GCP GKE         │                │
│  │  (Simulated)     │              │  (Simulated)     │                │
│  │  No Real Cost    │              │  No Real Cost    │                │
│  └──────────────────┘              └──────────────────┘                │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Source Control (GitHub)

**Purpose**: Version control and source of truth

**Components**:
- Application code (`app/`)
- Infrastructure as Code (`infra/`)
- Kubernetes manifests (`k8s/`)
- ArgoCD configuration (`argocd/`)

### 2. CI Pipeline (GitHub Actions)

**Purpose**: Automated build and container image creation

**Workflow** (`.github/workflows/ci.yml`):
1. Triggered on push to `main` branch
2. Authenticates with AWS using OIDC
3. Builds Docker image
4. Tags with commit SHA
5. Pushes to Amazon ECR
6. Updates Kubernetes manifest with new image tag
7. Commits manifest change back to Git

**Security**: Uses OIDC for AWS authentication (no hardcoded credentials)

### 3. Container Registry (Amazon ECR)

**Purpose**: Store Docker images

**Configuration**:
- Repository: `gitops-app`
- Image scanning enabled
- Lifecycle policies for old images

### 4. CD Pipeline (ArgoCD)

**Purpose**: GitOps-based continuous deployment

**How it works**:
1. Watches Git repository for changes
2. Compares desired state (Git) vs actual state (cluster)
3. Automatically syncs differences
4. Self-heals if manual changes are made

**Configuration**:
- Auto-sync enabled
- Self-heal enabled
- Prune enabled (removes deleted resources)

### 5. Kubernetes Cluster (AWS EKS)

**Purpose**: Container orchestration platform

**Specifications**:
- Cluster version: 1.29
- Node type: t3.medium (Spot instances)
- Node count: 1-2 (auto-scaling)
- Networking: Custom VPC with private subnets

**Cost Optimization**:
- Spot instances (60-90% savings)
- Single NAT Gateway
- Right-sized instances

### 6. Application

**Purpose**: Sample microservice demonstrating the pipeline

**Tech Stack**:
- Language: Python 3.9
- Framework: Flask
- Server: Gunicorn
- Container: Docker

**Endpoints**:
- `/` - Returns app info and version
- `/health` - Health check endpoint

### 7. Infrastructure as Code (Terraform)

**Purpose**: Declarative infrastructure management

**Modules**:
- `aws/vpc` - Network infrastructure
- `aws/eks` - Kubernetes cluster
- `aws/ecr` - Container registry
- `azure-simulated/aks` - Simulated Azure cluster
- `gcp-simulated/gke` - Simulated GCP cluster

**State Management**:
- Backend: S3 + DynamoDB
- State locking enabled
- Encryption enabled

## Data Flow

### Deployment Flow

1. **Developer commits code** → GitHub
2. **GitHub Actions triggered** → Builds Docker image
3. **Image pushed** → Amazon ECR
4. **Manifest updated** → Git repository
5. **ArgoCD detects change** → Syncs to cluster
6. **Kubernetes deploys** → New pods created
7. **Old pods terminated** → Rolling update complete

### Request Flow

1. **User request** → Load Balancer
2. **Load Balancer** → Kubernetes Service
3. **Service** → Pod (round-robin)
4. **Pod** → Returns response

## Security Considerations

### IAM Least Privilege

- GitHub Actions role has minimal ECR permissions
- EKS nodes have minimal AWS permissions
- No hardcoded credentials anywhere

### Container Security

- Non-root user in Dockerfile
- Image scanning enabled in ECR
- Resource limits defined in Kubernetes

### Network Security

- Private subnets for EKS nodes
- Security groups restrict traffic
- HTTPS for ArgoCD UI

### Secrets Management

- Kubernetes Secrets for sensitive data
- AWS Secrets Manager integration (optional)
- No secrets in Git repository

## Multi-Cloud Simulation

### Why Simulate?

- **Cost**: Avoid paying for multiple cloud providers
- **Demonstration**: Show multi-cloud architecture knowledge
- **Portfolio**: Prove understanding without actual deployment

### How It Works

**Simulated Modules**:
- Use Terraform `local_file` resource
- Generate fake kubeconfig files
- Output mock endpoints
- No actual cloud API calls

**Benefits**:
- Zero cost for Azure/GCP
- Same Terraform structure as real deployments
- Easy to convert to real deployments later

## Scalability Considerations

### Horizontal Scaling

- Kubernetes HPA (Horizontal Pod Autoscaler)
- EKS node auto-scaling
- Multiple availability zones

### Vertical Scaling

- Resource requests/limits tunable
- Instance type easily changeable
- Cluster version upgradeable

## Monitoring & Observability

### Current Implementation

- CloudWatch Logs for EKS
- Kubernetes liveness/readiness probes
- ArgoCD application health status

### Future Enhancements

- Prometheus for metrics
- Grafana for dashboards
- Distributed tracing (Jaeger)
- Log aggregation (ELK stack)

## Cost Breakdown

### Monthly Costs (if left running)

| Component | Cost |
|-----------|------|
| EKS Control Plane | $73 |
| EC2 Instances (Spot) | $15-30 |
| NAT Gateway | $32 |
| Data Transfer | $5-10 |
| **Total** | **$125-145** |

### Cost Optimization Strategies

1. **Spot Instances**: 60-90% savings on compute
2. **Single NAT Gateway**: $32/month savings vs multi-AZ
3. **Right-sizing**: t3.medium instead of larger instances
4. **Destroy when not in use**: Zero cost when torn down

## Disaster Recovery

### Backup Strategy

- Infrastructure: Terraform state in S3 (versioned)
- Application: Code in Git
- Configurations: Kubernetes manifests in Git

### Recovery Procedure

1. Restore Terraform state from S3
2. Run `terraform apply`
3. ArgoCD auto-deploys from Git
4. Application restored

**RTO** (Recovery Time Objective): ~20 minutes
**RPO** (Recovery Point Objective): Last Git commit

## Future Enhancements

1. **Helm Charts**: Convert manifests to Helm for templating
2. **Multi-Environment**: Add staging/production environments
3. **Service Mesh**: Implement Istio for advanced traffic management
4. **Policy as Code**: Add OPA (Open Policy Agent) for governance
5. **Real Multi-Cloud**: Deploy to actual Azure/GCP clusters
