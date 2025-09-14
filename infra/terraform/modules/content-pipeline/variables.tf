variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }

variable "github_owner"  { type = string } # e.g., "OluOrija"
variable "github_repo"   { type = string } # e.g., "ekelola"
variable "workflow_name" { type = string } # e.g., "content-sync.yml"

# Secrets Manager name for a GitHub PAT with scopes: repo, workflow
variable "github_pat_secret_name" { type = string }

# Guardrails
variable "max_mdx_size_bytes" {
	type    = number
	default = 2000000
} # 2MB

# Optional KMS alias
variable "kms_alias" {
	type    = string
	default = "alias/ekelola-content"
}
