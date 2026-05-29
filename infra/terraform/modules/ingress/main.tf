locals {
  labels = {
    app        = "vhl-python-app"
    component  = "ingress"
    managed-by = "terraform"
  }

  tls_hosts = [
    var.host,
    "localhost"
  ]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = var.host
    organization = "VHL DevOps Local"
  }

  dns_names    = local.tls_hosts
  ip_addresses = ["127.0.0.1"]

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "kubernetes_secret_v1" "tls" {
  metadata {
    name      = var.tls_secret_name
    namespace = var.namespace

    labels = local.labels
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.this.cert_pem
    "tls.key" = tls_private_key.this.private_key_pem
  }
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = local.labels

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts       = local.tls_hosts
      secret_name = kubernetes_secret_v1.tls.metadata[0].name
    }

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.service_name

              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}