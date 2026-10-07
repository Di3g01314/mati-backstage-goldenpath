mock_provider "aws" {
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_iam_policy_document" { defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" } }
}
variables {
  cluster_name         = "goldenpath-test-eks"
  vpc_id               = "vpc-0123456789abcdef0"
  private_subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  kubernetes_version   = "1.31"
  addon_versions       = { coredns = "v1.0.0-eksbuild.1", kube-proxy = "v1.0.0-eksbuild.1", vpc-cni = "v1.0.0-eksbuild.1", eks-pod-identity-agent = "v1.0.0-eksbuild.1" }
  admin_principal_arns = { platform = "arn:aws:iam::111111111111:role/platform-admin" }
}
run "private_api_and_pod_identity_agent" {
  command = plan
  module { source = "./modules/eks" }
  assert {
    condition     = !aws_eks_cluster.this.vpc_config[0].endpoint_public_access && aws_eks_cluster.this.vpc_config[0].endpoint_private_access
    error_message = "EKS API must be private by default."
  }
  assert {
    condition     = contains(keys(aws_eks_addon.this), "eks-pod-identity-agent")
    error_message = "Pod Identity agent must be installed."
  }
}
run "reject_world_open_api" {
  command = plan
  module { source = "./modules/eks" }
  variables { public_access_cidrs = ["0.0.0.0/0"] }
  expect_failures = [var.public_access_cidrs]
}
