module "site" {
  source                = "../../modules/static_site"
  root_domain           = var.root_domain
  project_name          = var.project_name
  domain_name           = var.domain_name
  alternate_domain_name = var.alternate_domain_name
  hosted_zone_id        = var.hosted_zone_id
  logging_bucket_name   = var.logging_bucket_name
  site_bucket_name      = var.site_bucket_name
  enable_www_redirect   = var.enable_www_redirect
}