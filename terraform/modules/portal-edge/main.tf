resource "aws_lb" "internal" {
  name               = "${var.resource_prefix}-eks-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_cross_zone_load_balancing = true
  security_groups                  = [aws_security_group.nlb.id]
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

resource "aws_security_group" "apigw_vpc_link" {
  name        = "${var.resource_prefix}-vpc-link-sg"
  description = "API Gateway VPC Link ENIs"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_prefix}-vpc-link-sg"
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.resource_prefix}-vpc-link"
  security_group_ids = [aws_security_group.apigw_vpc_link.id]
  subnet_ids         = var.private_subnet_ids
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.resource_prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "nlb" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.http.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.this.id
  payload_format_version = "1.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "default" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "$default"
  authorization_type = "AWS_IAM"
  target             = "integrations/${aws_apigatewayv2_integration.nlb.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 50
    throttling_rate_limit    = 25
  }
}

resource "aws_security_group" "nlb" {
  name   = "${var.resource_prefix}-nlb"
  vpc_id = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "nlb_from_link" {
  security_group_id            = aws_security_group.nlb.id
  referenced_security_group_id = aws_security_group.apigw_vpc_link.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}
resource "aws_vpc_security_group_egress_rule" "link_to_nlb" {
  security_group_id            = aws_security_group.apigw_vpc_link.id
  referenced_security_group_id = aws_security_group.nlb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
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
