variable "project_name" { type = string }
variable "domain_name" { type = string }           # "ekelola.com"
variable "alternate_domain_name" { type = string } # "www.ekelola.com"
variable "hosted_zone_id" { type = string }        # Route53 zone ID
variable "logging_bucket_name" { type = string }   # "ekelola-cf-logs"
variable "site_bucket_name" { type = string }      # "ekelola-site"

variable "enable_www_redirect" {
  description = "If true, attach a CloudFront Function to redirect www → apex."
  type        = bool
  default     = true
}
