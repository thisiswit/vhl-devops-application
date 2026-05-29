locals {
  labels = {
    app        = var.name
    component  = "api"
    managed-by = "terraform"
  }
}

resource "kubernetes_config_map_v1" "app" {
  metadata {
    name      = "${var.name}-config"
    namespace = var.namespace

    labels = local.labels
  }

  data = {
    APP_NAME      = var.app_name
    APP_VERSION   = var.app_version
    POSTGRES_HOST = var.postgres_host
    POSTGRES_PORT = var.postgres_port
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app       = local.labels.app
        component = local.labels.component
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name              = var.name
          image             = var.image
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = var.postgres_secret_name
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = 15
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/db-check"
              port = "http"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace

    labels = local.labels

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path"   = "/metrics"
      "prometheus.io/port"   = "8000"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app       = local.labels.app
      component = local.labels.component
    }

    port {
      name        = "http"
      port        = 8000
      target_port = "http"
      protocol    = "TCP"
    }
  }
}