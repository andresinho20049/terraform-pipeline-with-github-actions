output "s3_dns" {
  value = aws_s3_bucket.s3_static_site_bucket.website_endpoint
  description = "The DNS name of the S3 bucket for static website hosting"
}

output "s3_static_site_bucket_name" {
  value = aws_s3_bucket.s3_static_site_bucket.bucket
  description = "The name of the S3 bucket for the static site."
}