variable "hosted_zone" {
  type = string
  default = "bughunter.life"
}
variable "cloudfront_hosted_zone_id" {}
variable "cloudfront_domain_name" {}
variable "cloudfront_additional_domain_name" {}
variable "domain_validation_options" {}