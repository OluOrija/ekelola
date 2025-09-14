variable "project_name" { type = string }
variable "root_domain" { type = string }
variable "domain_name" { type = string }
variable "alternate_domain_name" { type = string }
variable "hosted_zone_id" { type = string }
variable "logging_bucket_name" { type = string }
variable "site_bucket_name" { type = string }
variable "enable_www_redirect" {
  type    = bool
  default = true
}
