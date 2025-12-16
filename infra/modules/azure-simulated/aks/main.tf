variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

# Simulate the creation of an AKS cluster by creating a local file
# This proves the module logic "ran" without costing money
resource "local_file" "kubeconfig" {
  content  = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: https://simulated-aks.azure.com
    certificate-authority-data: MOCK_DATA
  name: ${var.cluster_name}
contexts:
- context:
    cluster: ${var.cluster_name}
    user: clusterUser_${var.resource_group_name}_${var.cluster_name}
  name: ${var.cluster_name}
current-context: ${var.cluster_name}
kind: Config
preferences: {}
users:
- name: clusterUser_${var.resource_group_name}_${var.cluster_name}
  user:
    token: MOCK_TOKEN
EOF
  filename = "${path.module}/../../../../simulated-aks-kubeconfig.yaml"
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = "https://simulated-aks.azure.com"
}

output "kubeconfig_path" {
  value = local_file.kubeconfig.filename
}
