# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# Variables that should be inherited from the account, region, environment in the inventory.
# ---------------------------------------------------------------------------------------------------------------------

# This variable is intended to be inherited from account.tfvars file in the terraform inventory
variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

# This variable is intended to be inherited from region.tfvars file in the terraform inventory
variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "website_domain_name" {
  description = "The name of the website and the S3 bucket to create (e.g. static.foo.com)."
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID where the entry will be created for var.website_domain_name."
}

variable "acm_certificate_domain_name" {
  description = "The domain name for which an ACM cert has been issues (e.g. *.foo.com).  Only used if var.create_route53_entry is true. Set to blank otherwise."
}

variable "custom_tags" {
  description = "A map of custom tags to apply to the S3 buckets. The key is the tag name and the value is the tag value."
  type        = "map"
  default     = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "create_route53_entry" {
  description = "If set to true, create a DNS A Record in Route 53 with the domain name in var.website_domain_name."
  default     = true
}

variable "enable_versioning" {
  description = "Set to true to enable versioning. This means the bucket will retain all old versions of all files. This is useful for backup purposes (e.g. you can rollback to an older version), but it may mean your bucket uses more storage."
  default     = true
}

variable "index_document" {
  description = "The path to the index document in the S3 bucket (e.g. index.html)."
  default     = "index.html"
}

variable "error_document" {
  description = "The path to the error document in the S3 bucket (e.g. error.html)."
  default     = "error.html"
}

# This variable is only set to true for testing. Not for production.
variable "force_destroy_access_logs_bucket" {
  description = "If set to true, this will force the delete of the access logs S3 bucket when you run terraform destroy, even if there is still content in it. This is only meant for testing and should not be used in production."
  default     = false
}

variable "error_404_response_code" {
  description = "The HTTP status code that you want CloudFront to return with the custom error page to the viewer when status 404 not found response is returned from the origin."
  default     = 404
}

variable "error_500_response_code" {
  description = "The HTTP status code that you want CloudFront to return with the custom error page to the viewer when status 500 internal server error response is returned from the origin."
  default     = 500
}

variable "default_ttl" {
  description = "The default amount of time, in seconds, that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an 'Cache-Control max-age' or 'Expires' header."
  default     = 30
}

variable "max_ttl" {
  description = "The maximum amount of time, in seconds, that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of 'Cache-Control max-age', 'Cache-Control s-maxage', and 'Expires' headers."
  default     = 60
}

variable "min_ttl" {
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated."
  default     = 0
}

variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront will forward to the S3 bucket."
  type        = "list"
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  description = "CloudFront will cache the responses for these methods."
  type        = "list"
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Whether you want CloudFront to automatically compress content for web requests that include 'Accept-Encoding: gzip' in the request header."
  default     = true
}

variable "viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  default     = "allow-all"
}

variable "forward_query_string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin. If set to true, CloudFront will cache all query string parameters."
  default     = true
}

variable "forward_cookies" {
  description = "Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior. You can specify all, none or whitelist. If whitelist, you must define var.whitelisted_cookie_names."
  default     = "none"
}

variable "whitelisted_cookie_names" {
  description = "If you have specified whitelist in var.forward_cookies, the whitelisted cookies that you want CloudFront to forward to your origin."
  type        = "list"
  default     = []
}

variable "forward_headers" {
  description = "The headers you want CloudFront to forward to the origin. Set to * to forward all headers."
  type        = "list"
  default     = []
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100. Higher price classes support more edge locations, but cost more. See: https://aws.amazon.com/cloudfront/pricing/#price-classes."
  default     = "PriceClass_100"
}

variable "access_logs_expiration_time_in_days" {
  description = "How many days to keep access logs around for before deleting them."
  default     = 30
}

variable "access_log_prefix" {
  description = "The folder in the access logs bucket where logs should be written."
  default     = ""
}
