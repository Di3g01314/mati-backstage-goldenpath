resource "aws_lb" "internal" {
  name               = "${var.resource_prefix}-eks-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_cross_zone_load_balancing                             = true
  security_groups                                              = [aws_security_group.nlb.id]
  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
}

resource "aws_lb_target_group" "istio" {
  name        = "${var.resource_prefix}-eks-tg"
  port        = 30080
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "istio" {
  autoscaling_group_name = var.node_autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.istio.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio.arn
  }
}

resource "aws_security_group" "nlb" {
  name   = "${var.resource_prefix}-nlb"
  vpc_id = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "nlb_from_link" {
  security_group_id = aws_security_group.nlb.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "nlb_to_nodes" {
  security_group_id            = aws_security_group.nlb.id
  referenced_security_group_id = var.node_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}
resource "aws_vpc_security_group_ingress_rule" "nodes_from_nlb" {
  security_group_id            = var.node_security_group_id
  referenced_security_group_id = aws_security_group.nlb.id
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}

resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.resource_prefix}-portal"
  target_arns = [aws_lb.internal.arn]
}
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.resource_prefix}-portal"
  endpoint_configuration { types = ["REGIONAL"] }
  binary_media_types = ["image/*", "font/*", "application/octet-stream"]
}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
  for_each           = { root = aws_api_gateway_rest_api.this.root_resource_id, proxy = aws_api_gateway_resource.proxy.id }
  rest_api_id        = aws_api_gateway_rest_api.this.id
  resource_id        = each.value
  http_method        = "ANY"
  authorization      = "NONE" # Backstage authenticates API requests; static assets/OAuth callbacks remain accessible.
  request_parameters = each.key == "proxy" ? { "method.request.path.proxy" = true } : {}
}
resource "aws_api_gateway_integration" "proxy" {
  for_each                = aws_api_gateway_method.proxy
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  uri                     = each.key == "proxy" ? "http://${aws_lb.internal.dns_name}/{proxy}" : "http://${aws_lb.internal.dns_name}/"
  request_parameters      = each.key == "proxy" ? { "integration.request.path.proxy" = "method.request.path.proxy" } : {}
  timeout_milliseconds    = 29000
}
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers    = { redeployment = sha1(jsonencode(aws_api_gateway_integration.proxy)) }
  lifecycle { create_before_destroy = true }
}
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "dev"
}
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"
  settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 25
    metrics_enabled        = true
  }
}
resource "aws_wafv2_web_acl" "this" {
  name  = "${var.resource_prefix}-portal"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.resource_prefix}-portal"
    sampled_requests_enabled   = false
  }
  rule {
    name     = "request-rate"
    priority = 1
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.resource_prefix}-rate"
      sampled_requests_enabled   = false
    }
  }
}
resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
