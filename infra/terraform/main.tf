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

module "application" {
  source = "./modules/application"

  namespace            = module.namespace.name
  name                 = var.application_name
  app_version          = var.application_version
  image                = var.application_image
  replicas             = var.application_replicas
  postgres_host        = module.database.service_host
  postgres_secret_name = module.database.secret_name

  depends_on = [
    module.database
  ]
}

module "ingress" {
  source = "./modules/ingress"

  namespace    = module.namespace.name
  host         = var.ingress_host
  service_name = module.application.service_name
  service_port = module.application.service_port

  depends_on = [
    module.application
  ]
}