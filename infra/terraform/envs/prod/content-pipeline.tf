terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" { region = "eu-west-2" }

module "content_pipeline" {
  source  = "../../modules/content-pipeline"
  project = "ekelola"
  env     = "prod"
  region  = "eu-west-2"

  github_owner           = "OluOrija"
  github_repo            = "ekelola"
  workflow_name          = "content-sync.yml"
  github_pat_secret_name = "ekelola/github/pat_content_sync"
  kms_alias              = "alias/ekelola-content"
  max_mdx_size_bytes     = 2000000
}

output "incoming_bucket" { value = module.content_pipeline.incoming_bucket }
output "live_bucket"     { value = module.content_pipeline.live_bucket }
output "rejected_bucket" { value = module.content_pipeline.rejected_bucket }
