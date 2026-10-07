variable "resource_prefix" {
  description = "Project resource prefix."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for subnet discovery."
  type        = string
}

variable "vpc_cidr" {
  description = "Dedicated VPC CIDR; verify overlap before deployment."
  type        = string
}

variable "availability_zones" {
  description = "One AZ per subnet in each tier."
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2 && length(distinct(var.availability_zones)) == length(var.availability_zones) && length(var.public_subnet_cidrs) == length(var.availability_zones) && length(var.private_subnet_cidrs) == length(var.availability_zones) && length(var.data_subnet_cidrs) == length(var.availability_zones)
    error_message = "Use at least two distinct AZs and one public, private and data subnet per AZ."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private application subnet CIDRs with NAT."
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "Isolated database subnet CIDRs."
  type        = list(string)
}
