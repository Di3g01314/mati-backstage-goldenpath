variable "cluster_name" {
  description = "Dedicated EKS name."
  type        = string
}

variable "vpc_id" {
  description = "Dedicated VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private application subnets."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Supported version to verify before deployment."
  type        = string
}

variable "addon_versions" {
  description = "Exact compatible versions: coredns, kube-proxy, vpc-cni and eks-pod-identity-agent."
  type        = map(string)
  validation {
    condition     = alltrue([for name in ["coredns", "kube-proxy", "vpc-cni", "eks-pod-identity-agent"] : contains(keys(var.addon_versions), name)])
    error_message = "Pin all four required EKS add-ons."
  }
}

variable "admin_principal_arns" {
  description = "Existing administrator roles keyed by stable names; no IAM users are created."
  type        = map(string)
  validation {
    condition     = length(var.admin_principal_arns) > 0
    error_message = "Provide at least one existing admin role."
  }
}

variable "public_access_cidrs" {
  description = "Allowed admin CIDRs; empty means private-only endpoint."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for cidr in var.public_access_cidrs : can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"])
    error_message = "Use restricted IPv4 admin CIDRs or none for private-only access."
  }
}

variable "node_instance_types" {
  description = "Worker instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum workers."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired workers; capacity for the new platform remains unverified."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum workers."
  type        = number
  default     = 3
}
