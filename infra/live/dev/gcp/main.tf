provider "local" {}

module "gcp_gke" {
  source = "../../../modules/gcp-simulated/gke"

  project_id   = "gitops-project-id"
  region       = "us-central1"
  cluster_name = "gke-gitops-dev"
}

output "simulated_endpoint" {
  value = module.gcp_gke.cluster_endpoint
}
