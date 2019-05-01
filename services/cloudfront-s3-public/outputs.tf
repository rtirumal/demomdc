# ---------------------------------------------------------------------------------------------------------------------
# Website Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "cloudfront_domain_names" {
  value = "${module.cloudfront.cloudfront_domain_names}"
}

output "cloudfront_id" {
  value = "${module.cloudfront.cloudfront_id}"
}

output "cloudfront_origin_access_identity_iam_arn" {
  value = "${module.cloudfront.cloudfront_origin_access_identity_iam_arn}"
}

output "cloudfront_access_logs_bucket_arn" {
  value = "${module.cloudfront.access_logs_bucket_arn}"
}

output "website_domain_name" {
  value = "${module.static_website.website_domain_name}"
}

output "website_bucket_arn" {
  value = "${module.static_website.website_bucket_arn}"
}

output "website_bucket_endpoint" {
  value = "${module.static_website.website_bucket_endpoint}"
}

output "website_access_logs_bucket_arn" {
  value = "${module.static_website.access_logs_bucket_arn}"
}

# All the above domain names are virtual-host-style domain names of the format <bucket-name>.s3.amazonaws.com, which
# only work over HTTP. This output uses a path-style domain name of the format s3-<region>.amazonaws.com/<bucket-name>,
# which will work over both HTTP and HTTPS. For more info, see:
# https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#access-bucket-intro
output "website_bucket_endpoint_path_style" {
  value = "${module.static_website.website_bucket_endpoint_path_style}"
}
