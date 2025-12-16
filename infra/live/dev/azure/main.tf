provider "local" {}

module "azure_aks" {
  source = "../../../modules/azure-simulated/aks"

  resource_group_name = "rg-gitops-dev"
  cluster_name        = "aks-gitops-dev"
  node_count          = 2
}

output "simulated_endpoint" {
  value = module.azure_aks.cluster_endpoint
}
