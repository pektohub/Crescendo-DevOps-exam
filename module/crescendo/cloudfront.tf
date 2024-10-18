
# Create CloudFront distribution using ALB as the origin
resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name =  aws_lb.alb.dns_name
    origin_id   = "ALB-Origin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"  # Communicate with the ALB using HTTPS
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-Origin"

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
  }

  # Add custom domain name (replace with your own domain)
  aliases = ["nginx.aurbano.com", "tomcat.aurbano.com"]  # Replace with your custom domain name

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.acm.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  price_class = "PriceClass_100"  # Cheapest price tier (USA, Canada, Europe)

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project-name}-Cloudfront"
    Manage      = var.tags_manage
    Environment = var.tags_env

  }
}
