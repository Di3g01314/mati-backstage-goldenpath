variable "role_name" {
  description = "Dedicated controller role name."
  type        = string
}

variable "cluster_name" {
  description = "Target EKS cluster."
  type        = string
}

variable "namespace" {
  description = "Controller namespace."
  type        = string
}

variable "service_account" {
  description = "Stable controller service account; configure it in the chart."
  type        = string
}

variable "policy_json" {
  description = "Explicit scoped IAM permissions; no default broad policy."
  type        = string
}
