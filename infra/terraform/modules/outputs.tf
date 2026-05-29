output "app_namespace" {
  description = "Application namespace created in Kubernetes."
  value       = module.namespace.name
}