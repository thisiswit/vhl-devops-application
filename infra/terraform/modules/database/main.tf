locals {
  labels = {
    app        = "postgres"
    component  = "database"
    managed-by = "terraform"
  }
}

resource "kubernetes_secret_v1" "postgres" {
  metadata {
    name      = "${var.name}-secret"
    namespace = var.namespace

    labels = local.labels
  }

  type = "Opaque"

  data = {
    POSTGRES_DB       = var.database_name
    POSTGRES_USER     = var.database_user
    POSTGRES_PASSWORD = var.database_password
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  wait_until_bound = false

  metadata {
    name      = "${var.name}-pvc"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

resource "kubernetes_deployment_v1" "postgres" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    replicas = 1

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
          name              = "postgres"
          image             = var.image
          image_pull_policy = "IfNotPresent"

          port {
            name           = "postgres"
            container_port = 5432
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.postgres.metadata[0].name
            }
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
              ]
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
              ]
            }

            initial_delay_seconds = 30
            period_seconds        = 20
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

        volume {
          name = "postgres-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.postgres.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    type = "ClusterIP"

    selector = {
      app       = local.labels.app
      component = local.labels.component
    }

    port {
      name        = "postgres"
      port        = 5432
      target_port = "postgres"
      protocol    = "TCP"
    }
  }
}