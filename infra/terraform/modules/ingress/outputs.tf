output "ingress_name" {
  description = "Ingress resource name."
  value       = kubernetes_ingress_v1.this.metadata[0].name
}

output "tls_secret_name" {
  description = "TLS Secret name."
  value       = kubernetes_secret_v1.tls.metadata[0].name
}

output "host" {
  description = "Ingress local host."
  value       = var.host
}