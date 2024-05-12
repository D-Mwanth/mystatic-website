output "route53_record" {
  value = module.route53.website_dns_record
}

output "bucket_name" {
  value = module.bucket.bucket_name
}