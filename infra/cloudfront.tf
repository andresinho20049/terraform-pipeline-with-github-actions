resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
    name                              = "${var.account_username}-${var.region}-${var.bucket_suffix_name}-s3-oac-${var.environment}"
    description                       = "OAC for S3 ${aws_s3_bucket.s3_static_site_bucket.bucket}"
    origin_access_control_origin_type  = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"

    depends_on = [ aws_s3_bucket.s3_static_site_bucket, aws_s3_bucket_versioning.s3_static_site_bucket_versioning ]
}

resource "aws_cloudfront_distribution" "cloudfront_s3_static_website" {
    enabled             = true
    is_ipv6_enabled     = true
    comment             = "CloudFront for S3 ${aws_s3_bucket.s3_static_site_bucket.bucket}"
    default_root_object = "index.html"

    origin {
        domain_name              = aws_s3_bucket.s3_static_site_bucket.bucket_regional_domain_name
        origin_id                = aws_s3_bucket.s3_static_site_bucket.id
        origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    }

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.s3_static_site_bucket.id
        cache_policy_id = aws_cloudfront_cache_policy.cloudfront_s3_static_site_cache_policy.id

        viewer_protocol_policy = "redirect-to-https"
    }

    viewer_certificate {
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    tags = {
        Name = "${var.account_username}.${var.region}.${var.bucket_suffix_name}.cloudfront.${var.environment}"
    }
    depends_on = [aws_s3_bucket.s3_static_site_bucket, aws_cloudfront_origin_access_control.cloudfront_s3_oac, aws_cloudfront_cache_policy.cloudfront_s3_static_site_cache_policy]
}

resource "aws_cloudfront_cache_policy" "cloudfront_s3_static_site_cache_policy" {
    name = "${var.account_username}-${var.region}-${var.bucket_suffix_name}-cache-policy-${var.environment}"
    comment = "Cache policy for S3 static site"
    default_ttl = 3600
    max_ttl = 86400
    min_ttl = 0

    parameters_in_cache_key_and_forwarded_to_origin {
        cookies_config {
            cookie_behavior = "none"
        }
        headers_config {
            header_behavior = "none"
        }
        query_strings_config {
            query_string_behavior = "none"
        }
    }
}