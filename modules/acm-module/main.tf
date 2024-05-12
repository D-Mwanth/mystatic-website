# Get the certificate from AWS ACM
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain
  subject_alternative_names = [
    var.additional_acm_domain_name,
  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}