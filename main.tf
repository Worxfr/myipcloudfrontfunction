# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # CloudFront functions are global, but we need to specify a region for the provider
}

# Configure the S3 backend
terraform {
  backend "s3" {
  }
  
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

# Create a random pet name for the S3 bucket
resource "random_pet" "bucket_name" {
  prefix = "static-content"
  length = 4
}

# Create an S3 bucket for static content with the random name
resource "aws_s3_bucket" "static_content" {
  bucket = random_pet.bucket_name.id
}

resource "aws_s3_bucket_public_access_block" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create the CloudFront function
resource "aws_cloudfront_function" "ip_returner" {
  name    = "ip-returner"
  runtime = "cloudfront-js-1.0"
  comment = "Function to return the IP address of the requester"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var clientIP = event.viewer.ip;
      
      var response = {
        statusCode: 200,
        statusDescription: "OK",
        headers: {
          "content-type": { value: "text/plain" }
        },
        body: "Your IP address is: " + clientIP
      };
      
      return response;
    }
  EOT
}

# Create a CloudFront distribution
resource "aws_cloudfront_distribution" "ip_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for IP returner function"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_content.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_content.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.ip_returner.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Create a CloudFront origin access identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${aws_s3_bucket.static_content.id}"
}

# Create a bucket policy to allow CloudFront to access the S3 bucket
resource "aws_s3_bucket_policy" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_content.arn}/*"
      }
    ]
  })
}

# Output the CloudFront distribution domain name
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.ip_distribution.domain_name
}

# Output the S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.static_content.id
}
