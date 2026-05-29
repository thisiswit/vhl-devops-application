variable "namespace" {
  description = "Namespace where network policies will be applied."
  type        = string
}

variable "app_name" {
  description = "Application pod app label."
  type        = string
  default     = "vhl-python-app"
}

variable "database_name" {
  description = "Database pod app label."
  type        = string
  default     = "postgres"
}

variable "ingress_namespace" {
  description = "Namespace where the ingress controller is running."
  type        = string
  default     = "kube-system"
}

variable "monitoring_namespace" {
  description = "Namespace where Prometheus is running."
  type        = string
  default     = "monitoring"
}

variable "dns_namespace" {
  description = "Namespace where CoreDNS is running."
  type        = string
  default     = "kube-system"
}