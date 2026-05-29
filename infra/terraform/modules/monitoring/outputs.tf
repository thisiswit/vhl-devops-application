output "namespace" {
  description = "Monitoring namespace."
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "release_name" {
  description = "Monitoring Helm release name."
  value       = helm_release.kube_prometheus_stack.name
}

output "prometheus_service_name" {
  description = "Prometheus service name."
  value       = "${var.release_name}-kube-prometheus-prometheus"
}

output "grafana_service_name" {
  description = "Grafana service name."
  value       = "${var.release_name}-grafana"
}

output "alertmanager_service_name" {
  description = "Alertmanager service name."
  value       = "${var.release_name}-kube-prometheus-alertmanager"
}