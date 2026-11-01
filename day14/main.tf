resource "random_id" "bucket_suffix" {
  byte_length = 4

  keepers = {
    project_name = var.project_name
    environment  = var.environment
  }
}

resource "aws_s3_bucket" "web" {
  bucket = "${var.project_name}-web-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id

  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_distribution" "web" {
  depends_on = [aws_s3_object.web]

  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
    origin_id                = aws_s3_bucket.web.id
  }

  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.web.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "terraform_data" "web" {
  input = "trigger-invalidation"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.web]
    }
  }
}

resource "aws_s3_object" "web" {
  for_each = fileset("${path.module}/www/", "**/*")

  # Versioning must be fully enabled before uploading,
  # Otherwise the post-upload read of the new object version can 404.
  depends_on = [aws_s3_bucket_versioning.web]

  bucket = aws_s3_bucket.web.id
  key    = each.value
  source = "${path.module}/www/${each.value}"
  content_type = lookup(
    local.mime_types,
    element(reverse(split(".", each.value)), 0),
    "application/octet-stream"
  )
  etag = filemd5("${path.module}/www/${each.value}")
  server_side_encryption = "AES256"
}
