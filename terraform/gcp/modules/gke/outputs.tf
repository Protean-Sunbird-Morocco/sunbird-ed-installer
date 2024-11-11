output "worker_pool_name" {
  description = "The name of the worker node pool"
  value       = google_container_node_pool.worker_pool.name
}

output "worker_pool_size" {
  description = "The size (machine type) of the worker node pool"
  value       = google_container_node_pool.worker_pool.node_config[0].machine_type
}

output "node_count" {
  description = "The initial number of nodes in the worker node pool"
  value       = google_container_node_pool.worker_pool.node_count
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = google_container_cluster.primary.name
}

output "namespace" {
  description = "The Kubernetes namespace"
  value       = "sunbird"
}

