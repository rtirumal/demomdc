# Create EC2 Container Registry Repos

This Terraform Module creates an [EC2 Container Registry 
(ECR)](http://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) Repo, which is where Docker images 
can be uploaded. Note that ECR is an alternative to [Docker Hub](https://hub.docker.com/). 

## Module Specific Usage Notes

This module can be used to create one or more repos. The `repo_names` variable is a list.

``` HCL
variable "repo_names" {
  description = "A list of names of the apps you want to store in ECR. One ECR repository will be created for each name."
  type        = "list"
}
```

## How do you use this module?

See the [root README](/) for instructions on using modules.

## Core concepts

For more information, check out the [EC2 Container Registry (ECR)
documentation](http://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html).
