output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.cloudfront_s3_static_website.domain_name}"
  description = "The HTTPS URL of the CloudFront distribution for the S3 static site."
}

output "s3_static_site_bucket_name" {
  value = aws_s3_bucket.s3_static_site_bucket.bucket
  description = "The name of the S3 bucket for the static site."
}