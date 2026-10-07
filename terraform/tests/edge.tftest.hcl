mock_provider "aws" {}
run "private_backend_and_authenticated_gateway" {
  command = plan
  module { source = "./modules/portal-edge" }
  variables {
    resource_prefix             = "goldenpath-test"
    vpc_id                      = "vpc-0123456789abcdef0"
    private_subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    node_autoscaling_group_name = "goldenpath-test-workers"
    node_security_group_id      = "sg-0123456789abcdef0"
  }
  assert {
    condition     = aws_lb.internal.internal && aws_apigatewayv2_route.default.authorization_type == "AWS_IAM"
    error_message = "NLB must be internal and requests must not be anonymous."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.nodes_from_nlb.from_port == 30080 && aws_vpc_security_group_ingress_rule.nodes_from_nlb.to_port == 30080
    error_message = "NLB must only reach the selected ingress NodePort."
  }
}
