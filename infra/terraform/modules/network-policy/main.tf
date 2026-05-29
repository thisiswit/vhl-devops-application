locals {
  common_labels = {
    managed-by = "terraform"
    component  = "network-policy"
  }

  app_selector = {
    app       = var.app_name
    component = "api"
  }

  database_selector = {
    app       = var.database_name
    component = "database"
  }
}

resource "kubernetes_network_policy_v1" "default_deny" {
  metadata {
    name      = "default-deny-all"
    namespace = var.namespace

    labels = local.common_labels
  }

  spec {
    pod_selector {}

    policy_types = [
      "Ingress",
      "Egress"
    ]
  }
}

resource "kubernetes_network_policy_v1" "allow_ingress_to_app" {
  metadata {
    name      = "allow-ingress-to-app"
    namespace = var.namespace

    labels = local.common_labels
  }

  spec {
    pod_selector {
      match_labels = local.app_selector
    }

    policy_types = [
      "Ingress"
    ]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.ingress_namespace
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "8000"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.monitoring_namespace
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "8000"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "allow_app_egress" {
  metadata {
    name      = "allow-app-egress"
    namespace = var.namespace

    labels = local.common_labels
  }

  spec {
    pod_selector {
      match_labels = local.app_selector
    }

    policy_types = [
      "Egress"
    ]

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.dns_namespace
          }
        }

        pod_selector {
          match_labels = {
            "k8s-app" = "kube-dns"
          }
        }
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }

      ports {
        protocol = "TCP"
        port     = "53"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = local.database_selector
        }
      }

      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "allow_app_to_database" {
  metadata {
    name      = "allow-app-to-database"
    namespace = var.namespace

    labels = local.common_labels
  }

  spec {
    pod_selector {
      match_labels = local.database_selector
    }

    policy_types = [
      "Ingress"
    ]

    ingress {
      from {
        pod_selector {
          match_labels = local.app_selector
        }
      }

      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
  }
}