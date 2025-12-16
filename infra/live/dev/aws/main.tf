provider "aws" {
  region = "us-east-1"
}

# Backend configuration - UNCOMMENT AFTER RUNNING BOOTSTRAP
# terraform {
#   backend "s3" {
#     bucket         = "REPLACE_WITH_YOUR_BUCKET_NAME"
#     key            = "live/dev/aws/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "gitops-pipeline-locks"
#     encrypt        = true
#   }
# }

locals {
  environment = "dev"
  cluster_name = "gitops-cluster-dev"
}

module "vpc" {
  source = "../../modules/aws/vpc"

  environment = local.environment
  cluster_name = local.cluster_name
}

module "eks" {
  source = "../../modules/aws/eks"

  environment  = local.environment
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}
