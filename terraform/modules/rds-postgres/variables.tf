variable "identifier" {
  description = "Backstage RDS instance name."
  type        = string
}

variable "vpc_id" {
  description = "Dedicated VPC ID."
  type        = string
}

variable "data_subnet_ids" {
  description = "Isolated database subnets."
  type        = list(string)
}

variable "client_security_group_ids" {
  description = "Explicit clients keyed by stable names. Node SG is not namespace isolation."
  type        = map(string)
}

variable "engine_version" {
  description = "Exact PostgreSQL version to verify in the target region."
  type        = string
}

variable "instance_class" {
  description = "Backstage development DB size."
  type        = string
  default     = "db.t4g.micro"
}

variable "final_snapshot_suffix" {
  description = "Unique suffix for final snapshot; change for each lifecycle."
  type        = string
}
