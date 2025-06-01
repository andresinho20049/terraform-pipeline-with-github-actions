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
}

# Public access block
resource "aws_s3_bucket_public_access_block" "s3_static_site_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Enable bucket policy for public read access
resource "aws_s3_bucket_policy" "s3_static_site_bucket_policy" {
  bucket = aws_s3_bucket.s3_static_site_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_static_site_bucket.arn}/*"
      }
    ]
  })
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
}