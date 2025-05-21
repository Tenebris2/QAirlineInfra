# Create the bucket
resource "aws_s3_bucket" "deployment_bucket" {
  bucket = var.bucket_name

  tags = {
    Name       = var.bucket_name
    Created_By = var.created_by
  }

  force_destroy = true
}

resource "aws_s3_bucket" "s3_access_logs" {
  bucket        = "qairline-s3-access-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_logging" "deployment_bucket_logging" {
  bucket        = aws_s3_bucket.deployment_bucket.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "s3-access-logs/"
}

# Configure the bucket as a website
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.deployment_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.deployment_bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

# Access control list (ACL)
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
  bucket     = aws_s3_bucket.deployment_bucket.id
  acl        = "private"
}

# Bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.deployment_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.deployment_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.website_cdn.arn}"
          }
        }
      }
    ]
  })
}
