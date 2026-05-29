output "app_namespace" {
  description = "Application namespace created in Kubernetes."
  value       = module.namespace.name
}

output "database_service_name" {
  description = "PostgreSQL service name."
  value       = module.database.service_name
}

output "database_service_host" {
  description = "PostgreSQL internal DNS host."
  value       = module.database.service_host
}

output "database_secret_name" {
  description = "PostgreSQL secret name."
  value       = module.database.secret_name
}

output "application_deployment_name" {
  description = "Application deployment name."
  value       = module.application.deployment_name
}

output "application_service_name" {
  description = "Application service name."
  value       = module.application.service_name
}

output "application_service_port" {
  description = "Application service port."
  value       = module.application.service_port
}