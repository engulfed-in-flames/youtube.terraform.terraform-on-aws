resource "aws_s3_bucket" "bucket_using_list" {
  count  = 2
  bucket = "${local.bucket_name}-${count.index}"

  tags = merge(local.common_tags, {
    Name = "${local.bucket_name}-${count.index}"
  })
}

resource "aws_s3_bucket" "bucket_using_for_each" {
  for_each = toset(["foo", "bar"])
  bucket   = "${local.bucket_name}-${each.value}"

  tags = merge(local.common_tags, {
    Name = "${local.bucket_name}-${each.value}"
  })

  depends_on = [aws_s3_bucket.bucket_using_list]
}

resource "aws_s3_bucket_versioning" "main" {
  for_each = local.all_bucket_ids
  bucket   = each.value

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  for_each = local.all_bucket_ids
  bucket   = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  for_each = local.all_bucket_ids
  bucket   = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
