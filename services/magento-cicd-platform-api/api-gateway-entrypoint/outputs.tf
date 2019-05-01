output "api_gateway_id" {
  value = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
}

output "execution_arn" {
  value = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.execution_arn}"
}
