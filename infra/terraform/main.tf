module "namespace" {
  source = "./modules/namespace"

  name        = var.app_namespace
  environment = var.environment
}

module "namespace" {
  source = "./modules/namespace"

  name        = var.app_namespace
  environment = var.environment
}

module "database" {
  source = "./modules/database"

  namespace         = module.namespace.name
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = var.database_password
  storage_size      = var.database_storage_size
}