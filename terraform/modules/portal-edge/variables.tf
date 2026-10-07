variable "resource_prefix" {
  description = "Short prefix; final NLB name must fit AWS length limits."
  type        = string
}

variable "vpc_id" {
  description = "Dedicated VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private NLB and VPC Link subnets."
  type        = list(string)
}

variable "node_autoscaling_group_name" {
  description = "EKS managed node group ASG."
  type        = string
}

variable "node_security_group_id" {
  description = "Worker SG allowed from NLB on port 30080."
  type        = string
}
