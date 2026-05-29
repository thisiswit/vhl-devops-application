output "network_policy_names" {
  description = "Network policies created for application isolation."
  value = [
    kubernetes_network_policy_v1.default_deny.metadata[0].name,
    kubernetes_network_policy_v1.allow_ingress_to_app.metadata[0].name,
    kubernetes_network_policy_v1.allow_app_egress.metadata[0].name,
    kubernetes_network_policy_v1.allow_app_to_database.metadata[0].name
  ]
}