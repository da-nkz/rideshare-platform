# ── S3 Buckets ───────────────────────────────────────────────────
resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket = "${var.prefix}-${each.key}"
  tags = merge({ Name = "${var.prefix}-${each.key}" }, var.tags)
}
 
# ── Block All Public Access ──────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets
  bucket = aws_s3_bucket.this[each.key].id
 
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
 
# ── Server-Side Encryption ───────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets
  bucket = aws_s3_bucket.this[each.key].id
 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
 
# ── Versioning ───────────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "this" {
  for_each = var.buckets
  bucket = aws_s3_bucket.this[each.key].id
 
  versioning_configuration {
    status = each.value.versioning_enabled ? "Enabled" : "Suspended"
  }
}
 
# ── Lifecycle Policy ─────────────────────────────────────────────
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.buckets
  bucket = aws_s3_bucket.this[each.key].id
 
  rule {
    id = "expire-objects"
    status = "Enabled"
 
    expiration {
      days = each.value.expiration_days
    }
  }
}

