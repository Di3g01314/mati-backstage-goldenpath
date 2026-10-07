mock_provider "aws" {}
run "private_backend_and_authenticated_gateway" {
  command = plan
  module { source = "./modules/portal-edge" }
  variables {
    vpc_cidr                    = "10.60.0.0/16"
    resource_prefix             = "goldenpath-test"
    vpc_id                      = "vpc-0123456789abcdef0"
    private_subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    node_autoscaling_group_name = "goldenpath-test-workers"
    node_security_group_id      = "sg-0123456789abcdef0"
  }
  assert {
    condition     = aws_lb.internal.internal && aws_api_gateway_rest_api.this.endpoint_configuration[0].types == tolist(["REGIONAL"])
    error_message = "NLB must be internal and the portal must use the regional REST gateway with WAF."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.nodes_from_nlb.from_port == 30080 && aws_vpc_security_group_ingress_rule.nodes_from_nlb.to_port == 30080
    error_message = "NLB must only reach the selected ingress NodePort."
  }
}
