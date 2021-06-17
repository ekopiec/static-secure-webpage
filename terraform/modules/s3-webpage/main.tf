#Create S3 bucket to be used as a webpage
resource "aws_s3_bucket" "webpage_bucket" {
  bucket = "${var.subdomain}.${var.domain}"
  acl = "public-read"
  website {
    index_document = var.webpage_index
  }
}

#Create S3 bucket policy for access to bucket objects
resource "aws_s3_bucket_policy" "pub_ro" {
  bucket = aws_s3_bucket.webpage_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.webpage_bucket.arn,
          "${aws_s3_bucket.webpage_bucket.arn}/*",
        ]
      },
    ]
  })
}

#Create S3 bucket object for webpage index
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.webpage_bucket.id
  key = var.webpage_index
  content = var.webpage_index_content
  content_type = "text/html"
}

#Create Route53 zone for second level domain, if it doesn't exist.
resource "aws_route53_zone" "main" {
  name = var.domain
}

#Create CNAME record
resource "aws_route53_record" "dev-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_s3_bucket.webpage_bucket.bucket_domain_name]
}