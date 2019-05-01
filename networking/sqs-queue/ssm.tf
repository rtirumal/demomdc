#################################################
# AWS Systems Manager Parameter store
#################################################

resource "aws_ssm_parameter" "sqs_queue_endpoint" {
  #If there two custom tags `service_name`, and `env_name` provied, a Parameter store entry will be created with the queue url as the value.
  count = "${lookup(var.custom_tags,"service_name","") != "" && lookup(var.custom_tags,"env_name","") != ""? 1 : 0}" #Optional Register endpoint.
  name  = "/service-discovery/${lookup(var.custom_tags,"service_name","")}/${lookup(var.custom_tags,"env_name","")}"
  type  = "String" 
  value = "${module.sqs.queue_url}"
}
resource "aws_ssm_parameter" "sqs_queue_arn" {
  #If there two custom tags `service_name`, and `env_name` provied, a Parameter store entry will be created with the queue url as the value.
  count = "${lookup(var.custom_tags,"service_name","") != "" && lookup(var.custom_tags,"env_name","") != ""? 1 : 0}" #Optional Register endpoint.
  name  = "/service-discovery/${lookup(var.custom_tags,"service_name","")}-sqs/${lookup(var.custom_tags,"env_name","")}"
  type  = "String" 
  value = "${module.sqs.queue_arn}"
}
