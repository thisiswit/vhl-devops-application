locals {
  labels = {
    app        = "kube-prometheus-stack"
    component  = "monitoring"
    managed-by = "terraform"
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace

    labels = local.labels
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name             = var.release_name
  namespace        = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  create_namespace = false
  wait             = true
  timeout          = 900
  cleanup_on_fail  = true

  values = [
    yamlencode({
      additionalPrometheusRulesMap = {
        vhl-application-rules = {
          groups = [
            {
              name = "vhl.application.rules"

              rules = [
                {
                  alert = "AppDown"
                  expr  = "up{job=\"vhl-python-app\"} == 0"
                  for   = "1m"

                  labels = {
                    severity = "critical"
                    service  = "vhl-python-app"
                  }

                  annotations = {
                    summary     = "VHL Python application is down"
                    description = "The vhl-python-app target has been unreachable by Prometheus for more than 1 minute."
                  }
                }
              ]
            }
          ]
        }
      }
      grafana = {
        enabled       = true
        adminPassword = var.grafana_admin_password

        service = {
          type = "ClusterIP"
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "300m"
            memory = "256Mi"
          }
        }
      }

      alertmanager = {
        enabled = true

        alertmanagerSpec = {
          resources = {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }

      prometheusOperator = {
        enabled = true

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "300m"
            memory = "256Mi"
          }
        }
      }

      kubeStateMetrics = {
        enabled = true
      }

      nodeExporter = {
        enabled = true
      }

      prometheus = {
        prometheusSpec = {
          retention          = "6h"
          scrapeInterval     = "15s"
          evaluationInterval = "15s"

          resources = {
            requests = {
              cpu    = "150m"
              memory = "512Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false

          additionalScrapeConfigs = [
            {
              job_name     = "vhl-python-app"
              metrics_path = var.app_metrics_path

              kubernetes_sd_configs = [
                {
                  role = "service"

                  namespaces = {
                    names = [
                      var.app_namespace
                    ]
                  }
                }
              ]

              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scrape"]
                  action        = "keep"
                  regex         = "true"
                },
                {
                  source_labels = ["__meta_kubernetes_service_name"]
                  action        = "keep"
                  regex         = var.app_service_name
                },
                {
                  source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_path"]
                  action        = "replace"
                  target_label  = "__metrics_path__"
                  regex         = "(.+)"
                },
                {
                  source_labels = ["__address__", "__meta_kubernetes_service_annotation_prometheus_io_port"]
                  action        = "replace"
                  target_label  = "__address__"
                  regex         = "([^:]+)(?::\\d+)?;(\\d+)"
                  replacement   = "$1:$2"
                },
                {
                  source_labels = ["__meta_kubernetes_namespace"]
                  target_label  = "namespace"
                },
                {
                  source_labels = ["__meta_kubernetes_service_name"]
                  target_label  = "service"
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}