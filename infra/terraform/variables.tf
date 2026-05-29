variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used to connect to the Kubernetes cluster."
  type        = string
  default     = "~/.kube/config"
}

variable "app_namespace" {
  description = "Kubernetes namespace used by the application resources."
  type        = string
  default     = "vhl-app"
}

variable "environment" {
  description = "Environment name used to tag Kubernetes resources."
  type        = string
  default     = "local"
}

variable "database_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "vhl_db"
}

variable "database_user" {
  description = "PostgreSQL database user."
  type        = string
  default     = "vhl_user"
}

variable "database_password" {
  description = "PostgreSQL database password."
  type        = string
  sensitive   = true
  default     = "vhl_password"
}

variable "database_storage_size" {
  description = "PostgreSQL persistent volume size."
  type        = string
  default     = "1Gi"
}

variable "application_name" {
  description = "Application Kubernetes resource name."
  type        = string
  default     = "vhl-python-app"
}

variable "application_image" {
  description = "Application container image."
  type        = string
  default     = "vhl-devops-application:local"
}

variable "application_replicas" {
  description = "Number of application replicas."
  type        = number
  default     = 1
}

variable "application_version" {
  description = "Application version."
  type        = string
  default     = "0.1.0"
}

variable "ingress_host" {
  description = "Local hostname used by the Ingress."
  type        = string
  default     = "vhl.local"
}