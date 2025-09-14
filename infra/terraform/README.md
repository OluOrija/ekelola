# ekelola.com AWS Static Site Infra (Terraform)

This repo provisions:
- S3 (private) + CloudFront (HTTPS) static hosting for Astro build
- ACM certificate (us-east-1) for CloudFront
- Route53 A-alias for ekelola.com and www.ekelola.com
- Conditional CloudFront Function to redirect www → apex
- Remote state: S3 bucket + DynamoDB lock (eu-west-2)
- GitHub Actions OIDC IAM role for Terraform Plan/Apply
- CI: Plan on PR to infra/terraform, Apply on push to infra/terraform

## Usage

### 1. Bootstrap (run once)
```
cd infra/terraform/bootstrap
terraform init
terraform apply -auto-approve
# Add terraform_role_arn output to GitHub Secrets as AWS_TF_ROLE_ARN
```

### 2. Provision prod infra
```
cd ../envs/prod
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

### 3. CI
- Plan runs on PR to infra/terraform branch
- Apply runs on push to infra/terraform branch

## Acceptance
 S3 site/logs buckets in eu-west-2, block public access, versioning + SSE
 CloudFront distribution with aliases, TLSv1.2_2021, gzip/brotli, error mapping
 ACM cert in us-east-1 validated via Route53
 Route53 A-alias records for apex and www
 Conditional www→apex redirect
 Remote state S3+DynamoDB, GitHub OIDC role, AWS_TF_ROLE_ARN secret
 App CI can publish dist/ to ekelola-site and invalidate CloudFront

---

## Content Pipeline Module Usage (infra/terraform/modules/content-pipeline)

### Setting the GitHub PAT Secret
- Go to AWS Secrets Manager in the AWS Console.
- Create a secret named `ekelola/github/pat_content_sync`.
- Set the secret value to your GitHub Personal Access Token (PAT) with scopes: `repo`, `workflow`.
- The Lambda will read this secret to trigger GitHub Actions.

### Packaging Lambda Functions
- Before running `terraform apply`, run:
	```bash
	bash infra/terraform/modules/content-pipeline/lambda_src/package.sh
	```
- This will create the required Lambda zip files for deployment.

### Expected S3 Bucket Names
- `ekelola-prod-content-incoming`
- `ekelola-prod-content-live`
- `ekelola-prod-content-rejected`
