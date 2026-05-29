variable "namespace" {
  description = "Namespace where monitoring resources will be created."
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack."
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version."
  type        = string
  default     = "85.2.2"
}

variable "app_namespace" {
  description = "Namespace where the application is running."
  type        = string
}

variable "app_service_name" {
  description = "Application service name scraped by Prometheus."
  type        = string
}

variable "app_metrics_path" {
  description = "Application metrics endpoint."
  type        = string
  default     = "/metrics"
}

variable "app_metrics_port" {
  description = "Application metrics port."
  type        = number
  default     = 8000
}

variable "grafana_admin_password" {
  description = "Grafana admin password for local environment."
  type        = string
  sensitive   = true
  default     = "admin"
}