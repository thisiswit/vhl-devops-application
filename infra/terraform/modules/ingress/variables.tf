variable "namespace" {
  description = "Namespace where Ingress resources will be created."
  type        = string
}

variable "name" {
  description = "Ingress resource name."
  type        = string
  default     = "vhl-python-app-ingress"
}

variable "host" {
  description = "Main local hostname used by the Ingress TLS certificate."
  type        = string
  default     = "vhl.local"
}

variable "tls_secret_name" {
  description = "TLS Secret name used by the Ingress."
  type        = string
  default     = "vhl-python-app-tls"
}

variable "ingress_class_name" {
  description = "Ingress class name."
  type        = string
  default     = "traefik"
}

variable "service_name" {
  description = "Application service name."
  type        = string
}

variable "service_port" {
  description = "Application service port."
  type        = number
}