variable "namespace" {
  description = "Namespace where PostgreSQL resources will be created."
  type        = string
}

variable "name" {
  description = "Base name used by PostgreSQL resources."
  type        = string
  default     = "postgres"
}

variable "image" {
  description = "PostgreSQL container image."
  type        = string
  default     = "postgres:16-alpine"
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
}

variable "storage_size" {
  description = "PostgreSQL persistent volume size."
  type        = string
  default     = "1Gi"
}

variable "storage_class_name" {
  description = "StorageClass used by the PostgreSQL PVC."
  type        = string
  default     = "local-path"
}