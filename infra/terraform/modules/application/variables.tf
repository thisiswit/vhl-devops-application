variable "namespace" {
  description = "Namespace where application resources will be created."
  type        = string
}

variable "name" {
  description = "Application Kubernetes resource name."
  type        = string
  default     = "vhl-python-app"
}

variable "app_name" {
  description = "Application name exposed through environment variables."
  type        = string
  default     = "vhl-devops-application"
}

variable "app_version" {
  description = "Application version exposed through environment variables."
  type        = string
  default     = "0.1.0"
}

variable "image" {
  description = "Application container image."
  type        = string
}

variable "replicas" {
  description = "Number of application replicas."
  type        = number
  default     = 1
}

variable "postgres_host" {
  description = "PostgreSQL service host."
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL service port."
  type        = string
  default     = "5432"
}

variable "postgres_secret_name" {
  description = "Secret containing PostgreSQL credentials."
  type        = string
}