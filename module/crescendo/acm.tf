resource "aws_acm_certificate" "acm" {
  domain_name       = "aurbano.com"  # Replace with your actual domain
  validation_method = "DNS"

  # Optionally, request a certificate for subdomains as well
  subject_alternative_names = ["*.aurbano.com", "aurbano.com"]  # Replace with your subdomains if needed

  tags = {
    Name        = "${var.project-name}-ACM"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}