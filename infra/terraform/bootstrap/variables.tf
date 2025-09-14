variable "project_name" { type = string }
variable "state_bucket" { type = string } # "ekelola-tfstate"
variable "lock_table" { type = string }   # "ekelola-tflock"
variable "github_owner" { type = string } # "OluOrija"
variable "github_repo" { type = string }  # "ekelola"
variable "allowed_ref_main" { type = string }  # "refs/heads/main"
variable "allowed_ref_allbranches" { type = string }  # "refs/heads/infra/content-pipeline"

# For scoping least-privilege (optional)
variable "hosted_zone_id" { type = string }
variable "site_bucket_name" { type = string }
variable "logs_bucket_name" { type = string }
variable "site_content_incoming_bucket_name" { type = string }
variable "site_content_live_bucket_name" { type = string }
variable "site_content_rejected_bucket_name" { type = string }
