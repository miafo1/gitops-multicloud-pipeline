variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

# Simulate the creation of a GKE cluster
resource "local_file" "kubeconfig" {
  content  = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: https://simulated-gke.googleapis.com
    certificate-authority-data: MOCK_DATA
  name: gke_${var.project_id}_${var.region}_${var.cluster_name}
contexts:
- context:
    cluster: gke_${var.project_id}_${var.region}_${var.cluster_name}
    user: gke_${var.project_id}_${var.region}_${var.cluster_name}
  name: gke_${var.project_id}_${var.region}_${var.cluster_name}
current-context: gke_${var.project_id}_${var.region}_${var.cluster_name}
kind: Config
preferences: {}
users:
- name: gke_${var.project_id}_${var.region}_${var.cluster_name}
  user:
    token: MOCK_TOKEN
EOF
  filename = "${path.module}/../../../../simulated-gke-kubeconfig.yaml"
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = "https://simulated-gke.googleapis.com"
}

output "kubeconfig_path" {
  value = local_file.kubeconfig.filename
}
