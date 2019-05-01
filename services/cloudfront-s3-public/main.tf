# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A STATIC WEBSITE IN AN S3 BUCKET AND DEPLOY CLOUDFRONT AS A CDN WITH SSL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = "${var.aws_region}"

  # Provider version 2.X series is the latest.
  # This package was updated to fix breaking changes from 1.x to 2.x provider
  version = "~> 2.0"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "= 0.11.11"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE STATIC WEBSITE
# ---------------------------------------------------------------------------------------------------------------------

module "static_website" {
  source = "git::git@github.com:gruntwork-io/package-static-assets.git//modules/s3-static-website?ref=v0.4.3"

  website_domain_name = "${var.website_domain_name}"
  index_document      = "${var.index_document}"
  error_document      = "${var.error_document}"

  enable_versioning = "${var.enable_versioning}"

  custom_tags = "${var.custom_tags}"

  # This is only set here so we can easily run automated tests on this code. 
  # This should ALWAYS be FALSE in production
  force_destroy_access_logs_bucket = "${var.force_destroy_access_logs_bucket}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDFRONT WEB DISTRIBUTION
# ---------------------------------------------------------------------------------------------------------------------

module "cloudfront" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "git::git@github.com:gruntwork-io/package-static-assets.git//modules/s3-cloudfront?ref=v0.4.3"

  bucket_name                 = "${var.website_domain_name}"
  s3_bucket_is_public_website = true
  bucket_website_endpoint     = "${module.static_website.website_bucket_endpoint}"

  index_document     = "${var.index_document}"
  error_document_404 = "${var.error_document}"
  error_document_500 = "${var.error_document}"

  min_ttl     = "${var.min_ttl}"
  max_ttl     = "${var.max_ttl}"
  default_ttl = "${var.default_ttl}"

  create_route53_entries = "${var.create_route53_entry}"
  domain_names           = ["${var.website_domain_name}"]
  hosted_zone_id         = "${var.hosted_zone_id}"

  # If var.create_route53_entry is false, the aws_acm_certificate data source won't be created. Ideally, we'd just use
  # a conditional to only use that data source if var.create_route53_entry is true, but Terraform's conditionals are
  # not short-circuiting, so both branches would be evaluated. Therefore, we use this silly trick with "join" to get
  # back an empty string if the data source was not created.
  acm_certificate_arn = "${join(",", data.aws_acm_certificate.cert.*.arn)}"

  use_cloudfront_default_certificate = false

  # This is only set here so we can easily run automated tests on this code. You should NOT copy this setting into
  # your real applications.
  force_destroy_access_logs_bucket = "${var.force_destroy_access_logs_bucket}"

  error_404_response_code = "${var.error_404_response_code}"
  error_500_response_code = "${var.error_500_response_code}"

  allowed_methods = "${var.allowed_methods}"
  cached_methods  = "${var.cached_methods}"

  compress = "${var.compress}"

  viewer_protocol_policy = "${var.viewer_protocol_policy}"

  forward_query_string     = "${var.forward_query_string}"
  forward_cookies          = "${var.forward_cookies}"
  forward_headers          = "${var.forward_headers}"
  whitelisted_cookie_names = "${var.whitelisted_cookie_names}"

  price_class = "${var.price_class}"

  access_logs_expiration_time_in_days = "${var.access_logs_expiration_time_in_days}"
  access_log_prefix                   = "${var.access_log_prefix}"
}

# ---------------------------------------------------------------------------------------------------------------------
# FIND THE ACM CERTIFICATE
# If var.create_route53_entry is true, we need a custom TLS cert for our custom domain name. Here, we look for a
# cert issued by Amazon's Certificate Manager (ACM) for the domain name var.acm_certificate_domain_name.
# ---------------------------------------------------------------------------------------------------------------------

# Note that ACM certs for CloudFront MUST be in us-east-1!
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

data "aws_acm_certificate" "cert" {
  count    = "${var.create_route53_entry}"
  provider = "aws.east"

  domain   = "${var.acm_certificate_domain_name}"
  statuses = ["ISSUED"]
}
