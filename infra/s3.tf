# Create the S3 bucket
resource "aws_s3_bucket" "s3_static_site_bucket" {
  bucket = "${var.account_username}.${var.region}.${var.bucket_suffix_name}.${var.environment}"
}

# Enable versioning
resource "aws_s3_bucket_versioning" "s3_static_site_bucket_versioning" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [ aws_s3_bucket.s3_static_site_bucket ]
}

# Public access block
resource "aws_s3_bucket_public_access_block" "s3_static_site_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

  depends_on = [ aws_s3_bucket.s3_static_site_bucket ]
}

# Enable CloudFront access to the S3 bucket
resource "aws_s3_bucket_policy" "s3_static_site_bucket_policy" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_static_site_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.cloudfront_s3_static_website.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.s3_static_site_bucket, aws_s3_bucket_versioning.s3_static_site_bucket_versioning]
}

# Configure static website hosting
resource "aws_s3_bucket_website_configuration" "s3_static_site_bucket_website_config" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket.s3_static_site_bucket, aws_s3_bucket_versioning.s3_static_site_bucket_versioning ]
}

# Configure lifecycle rules for the bucket to remove old versions after a certain period 
resource "aws_s3_bucket_lifecycle_configuration" "s3_static_site_bucket_lifecycle" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id

  rule {
    id = "lifecycle_rule_remove_old_versions"
    status = "Enabled"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days = 30
    }
  }

  depends_on = [ aws_s3_bucket.s3_static_site_bucket, aws_s3_bucket_versioning.s3_static_site_bucket_versioning ]
}