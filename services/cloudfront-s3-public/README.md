# S3 + CloudFront + SSL SSL Static Website Package

This package deploys a CloudFront distribution as a Content Distribution Network (CDN) in front of a **public** S3 bucket with a custom SSL cert managed by **AWS ACM** and a domain managed in **Route53**

- CloudFront reduces latency for your users, by caching your static content in servers around the world.
- CloudFront also allows you to use SSL with the static content in an S3 bucket.

This configuration allows you to configure custom routing rules, custom error documents and other useful features for running a static website. The disadvantage is that you have to make your S3 bucket publicly accessible, which means users who know the URL could access the bucket directly, bypassing CloudFront. Despite this minor limitation, we recommend this option for most users, as it provides the best experience for running a website on S3. Request a new (different) package if this doesn't fit your use-case.

NOTE: For some reason, the Private S3 bucket option currently ONLY works in us-east1. In all other regions, you get 403: Access Denied errors. We are still investigating why, but for the time being, deploy your entire static website in us-east-1 and things will work fine.

## Quick Start

While it is expected that this module will be executed via terragrunt deployed to a terragrunt inventory with a terraform.tfvars file. It is possible to try or test these templates with Terraform installed:

### How to Try

1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
2. Run `terraform get`.
3. Run `terraform plan`.
4. If the plan looks good, run `terraform apply`.

When the `apply` command finishes, this module will output the domain name you can use to test the website in your
browser.

Note that a CloudFront distribution can take a LONG time to deploy (i.e. sometimes as much as 15 - 30 minutes!), so 
before testing the URL, head over to the [CloudFront distributions 
page](https://console.aws.amazon.com/cloudfront/home#distributions:) and wait for the "Status" of your distribution
to show up as "Deployed".

## How do I test my website?

This module outputs the domain name of your website using the `cloudfront_domain_name` output variable.

By default, the domain name will be of the form:

```
<ID>.cloudfront.net
```

Where `ID` is a unique ID generated for your CloudFront distribution. For example:

```
d111111abcdef8.cloudfront.net
```

If you set `var.create_route53_entry` to true, then this module will create a DNS A record in [Route 
53](https://aws.amazon.com/route53/) for your CloudFront distribution with the domain name in 
`var.domain_name`, and you will be able to use that custom domain name to access your bucket instead of the 
`amazonaws.com` domain.

## How do I configure HTTPS (SSL)?

If you are using the default `.cloudfront.net` domain name, then you can use it with HTTPS with no extra changes:

```
https://<ID>.cloudfront.net
```

If you are using a custom domain name, to use HTTPS, you need to specify the ARN of either an [AWS Certificate Manager
(ACM)](https://aws.amazon.com/certificate-manager/) certificate via the `acm_certificate_arn` parameter or a 
custom [certificate in IAM](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_server-certs.html) via the
`iam_certificate_id` parameter. We recommend using ACM certs as they are free, very quick to set up, and best of all,
AWS automatically renews them for you. 

**NOTE**: If you set either `acm_certificate_arn` or `iam_certificate_id` you must set `use_cloudfront_default_certificate`
to `false`.

## Limitations

To create a CloudFront distribution with Terraform, you use the [aws_cloudfront_distribution 
resource](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#viewer-certificate-arguments). 
Unfortunately, this resource primarily consists of "inline blocks", which do not work well in Terraform modules, as
there is no way to create them dynamically based on the module's inputs.

As a results, the CloudFront distribution in this module is limited to a fixed set of settings that should work for
most use cases, but is not particularly flexible. In particular, the limitations are as follows:

* Only one origin—an S3 bucket—is supported 
  ([origin](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) is an inline
  block). You specify the bucket to use via the `bucket_name` parameter.
  
* Only one set of geo restrictions is supported 
  ([geo_restrictions](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#restrictions-arguments) 
  is an inline block). You can optionally specify the restrictions via the `geo_restriction_type` and 
  `geo_locations_list` parameters.
  
* Only one default cache behavior is supported 
  ([cache behaviors](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#cache-behavior-arguments) 
  is an inline block). You can control the default cache settings using a number of parameters, including 
  `cached_methods`, `default_ttl`, `min_ttl`, `max_ttl`, and many others (see [vars.tf](vars.tf) for the full list).
  
* Only two error responses are supported 
  ([error responses](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#custom-error-response-arguments)
  is an inline block). You can specify the 404 and 500 response paths using the `error_document_404` and 
  `error_document_500` parameters, respectively.
  
* You can not specify specify query string parameters to cache 
  ([query_string_cache_keys](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#query_string_cache_keys)
  is an inline block nested in an inline block).

* [lambda_function_association](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#lambda_function_association)
  is not yet supported.
  
* [custom_header](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#custom_header) is not
  yet supported as it consists of inline blocks in an inline block.

If you absolutely need some of these features, the only solution available for now is to copy and paste this module
into your own codebase, using it as a guide, and adding the tweaks you need.