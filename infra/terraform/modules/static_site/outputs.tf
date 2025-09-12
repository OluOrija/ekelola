output "bucket_name" { value = aws_s3_bucket.site_bucket.id }
output "cloudfront_domain_name" { value = aws_cloudfront_distribution.site.domain_name }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.site.id }
output "certificate_arn" { value = aws_acm_certificate.cert.arn }
