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