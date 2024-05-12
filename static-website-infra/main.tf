terraform {
  backend "s3" {
    bucket         = "static-web-hosting-by-daniel"
    key            = "backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  # profile = "terraform-user"
}

# Create S3 bucket
module "bucket" {
  source           = "../modules/bucket"
  bucket_name      = "${var.business_name}-website-buck-${var.stage}"
  default_document = var.default_document
  error_document   = var.error_document
}

# Create ACM certificate
module "acm-module" {
  source                     = "../modules/acm-module"
  domain                     = var.domain_name
  additional_acm_domain_name = var.additional_acm_domain_name
}

# Create cloudfront
module "cloudfront" {
  source                 = "../modules/cloudfront-module"
  website_endpoint       = module.bucket.website_endpoint
  bucket_name            = module.bucket.bucket_name
  acm_certificate_arn    = module.acm-module.acm_arn
  additional_domain_name = var.additional_domain_name
  default_document       = var.default_document
  error_document         = var.error_document
}

# Create route53 record to validate acm certificate and to expose cloundfront endpoint
module "route53" {
  source                            = "../modules/route53-module"
  cloudfront_domain_name            = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id         = module.cloudfront.cloudfront_hosted_zone_id
  cloudfront_additional_domain_name = var.additional_domain_name
  domain_validation_options         = module.acm-module.domain_validation_options
}

# # Upload website content to s3 bucket
# resource "null_resource" "sync_s3_after_apply" {

#   depends_on = [module.bucket]

#   provisioner "local-exec" {
#     command     = "aws s3 sync /Users/paulodhiambo/Downloads/2119_gymso_fitness s3://hunters-website-buck-dev/"
#     interpreter = ["bash", "-c"]
#   }
# }