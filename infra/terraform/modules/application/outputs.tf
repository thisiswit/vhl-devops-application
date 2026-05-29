output "service_name" {
  description = "Application service name."
  value       = kubernetes_service_v1.app.metadata[0].name
}

output "service_port" {
  description = "Application service port."
  value       = 8000
}

output "deployment_name" {
  description = "Application deployment name."
  value       = kubernetes_deployment_v1.app.metadata[0].name
}