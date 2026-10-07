resource "aws_security_group" "database" {
  name        = "${var.identifier}-sg"
  description = "PostgreSQL from the explicitly supplied workload security groups"
  vpc_id      = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "postgres" {
  for_each                     = var.client_security_group_ids
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.data_subnet_ids
}
resource "aws_db_instance" "this" {
  identifier                  = var.identifier
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = "backstage"
  username                    = "backstage_admin"
  manage_master_user_password = true
  port                        = 5432
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.database.id]
  publicly_accessible         = false
  multi_az                    = false
  backup_retention_period     = 7
  deletion_protection         = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.identifier}-final-${var.final_snapshot_suffix}"
  auto_minor_version_upgrade  = true
  apply_immediately           = false
}
