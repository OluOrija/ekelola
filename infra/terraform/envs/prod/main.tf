module "site" {
  source                = "../../modules/static_site"
  project_name          = var.project_name
  domain_name           = var.domain_name
  alternate_domain_name = var.alternate_domain_name
  hosted_zone_id        = var.hosted_zone_id
  logging_bucket_name   = var.logging_bucket_name
  site_bucket_name      = var.site_bucket_name
  enable_www_redirect   = var.enable_www_redirect
}

output "cloudfront_domain" { value = module.site.cloudfront_domain_name }
output "distribution_id" { value = module.site.cloudfront_distribution_id }
output "site_bucket_name" { value = module.site.bucket_name }
