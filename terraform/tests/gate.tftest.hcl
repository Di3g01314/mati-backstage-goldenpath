mock_provider "aws" {
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_iam_policy_document" { defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" } }
}
override_module {
  target  = module.network
  outputs = { vpc_id = "vpc-test", private_subnet_ids = ["subnet-a", "subnet-b"], data_subnet_ids = ["subnet-c", "subnet-d"] }
}
override_module {
  target  = module.eks
  outputs = { cluster_name = "goldenpath-test-eks", node_security_group_id = "sg-test", node_autoscaling_group_name = "asg-test" }
}
override_module {
  target  = module.backstage_database
  outputs = { endpoint = "test.invalid", master_secret_arn = "arn:aws:secretsmanager:us-east-1:111111111111:secret:test" }
}
override_module {
  target  = module.ecr
  outputs = { repository_urls = { "goldenpath-dev/backstage" = "registry.example/backstage", "goldenpath-dev/service-v0" = "registry.example/service-v0" } }
}
run "deployment_blocked_by_default" {
  command = plan
  variables {
    aws_account_id           = "111111111111"
    owner                    = "test"
    cost_center              = "test"
    kubernetes_version       = "1.31"
    eks_addon_versions       = {}
    eks_admin_principal_arns = {}
    postgres_engine_version  = "16.4"
    final_snapshot_suffix    = "test"
  }
  expect_failures = [terraform_data.deployment_gate]
}
