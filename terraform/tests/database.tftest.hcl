mock_provider "aws" {}
run "private_encrypted_database_with_managed_credentials" {
  command = plan
  module { source = "./modules/rds-postgres" }
  variables {
    identifier                = "goldenpath-test-backstage"
    vpc_id                    = "vpc-0123456789abcdef0"
    data_subnet_ids           = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    client_security_group_ids = { backstage = "sg-0123456789abcdef0" }
    engine_version            = "16.4"
    final_snapshot_suffix     = "test"
  }
  assert {
    condition     = !aws_db_instance.this.publicly_accessible && aws_db_instance.this.storage_encrypted && aws_db_instance.this.manage_master_user_password
    error_message = "Database must be private, encrypted and use an AWS-managed password."
  }
  assert {
    condition     = aws_db_instance.this.deletion_protection && !aws_db_instance.this.skip_final_snapshot && aws_db_instance.this.backup_retention_period >= 7
    error_message = "Protect the database from accidental removal and retain backups."
  }
  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.postgres) == 1 && aws_vpc_security_group_ingress_rule.postgres["backstage"].referenced_security_group_id == "sg-0123456789abcdef0"
    error_message = "Only explicitly supplied client groups may connect."
  }
}
