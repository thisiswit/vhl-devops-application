output "service_name" {
  description = "PostgreSQL service name."
  value       = kubernetes_service_v1.postgres.metadata[0].name
}

output "service_host" {
  description = "PostgreSQL internal DNS service host."
  value       = "${kubernetes_service_v1.postgres.metadata[0].name}.${var.namespace}.svc.cluster.local"
}

output "service_port" {
  description = "PostgreSQL service port."
  value       = 5432
}

output "secret_name" {
  description = "PostgreSQL secret name."
  value       = kubernetes_secret_v1.postgres.metadata[0].name
}

output "database_name" {
  description = "PostgreSQL database name."
  value       = var.database_name
}

output "database_user" {
  description = "PostgreSQL database user."
  value       = var.database_user
}