resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      app         = "vhl-devops-application"
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}