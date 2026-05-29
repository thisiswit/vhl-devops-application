module "namespace" {
  source = "./modules/namespace"

  name        = var.app_namespace
  environment = var.environment
}