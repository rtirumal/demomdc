# Application Load Balancer (ALB)

This Terraform Module creates an [Application Load Balancer 
(ALB)](http://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) that can be used to route 
requests to an ECS Cluster or Auto Scaling Group. Under the hood, this is implemented using the Gruntwork 
[alb module](https://github.com/gruntwork-io/module-load-balancer/tree/master/modules/alb).

Note that a single ALB is designed to be shared among multiple ECS Clusters, ECS Services or Auto Scaling Groups, in 
contrast to an ELB ("Classic Load Balancer") which is typically associated with a single service. For this reason, the 
ALB is created separately from an ECS Cluster, ECS Service, or Auto Scaling Group.

## ALB Notes

The ALB gives us the following HTTP-specific functionality compared to the rest:

* Route requests via HTTP or HTTPS
* Native support for WebSockets
* Native support for HTTP/2
* Path-based routing
* Hostname-based routing
* Ability to route to a Target, which incorporates both an endpoint and a port and therefore allows different instances of an ECS Service to receive traffic on different ports.
* Supports specifying Security groups

## How do you use this module?

See the [root README](/) for instructions on using modules.

## Core concepts

To understand core concepts like what is an ALB, ELB vs. ALB, and how to use an ALB with an ECS Cluster and ECS Service,
the [alb module documentation](https://github.com/gruntwork-io/module-load-balancer/tree/master/modules/alb).