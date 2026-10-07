resource "terraform_data" "deployment_gate" {
  lifecycle {
    precondition {
      condition     = var.deployment_enabled
      error_message = "Deployment is disabled. Finish the deployment checklist and obtain explicit authorization before enabling it."
    }
  }
}
module "network" {
  source               = "./modules/network"
  resource_prefix      = var.resource_prefix
  cluster_name         = local.cluster_name
  vpc_cidr             = "10.60.0.0/16"
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = ["10.60.0.0/24", "10.60.1.0/24", "10.60.2.0/24"]
  private_subnet_cidrs = ["10.60.16.0/20", "10.60.32.0/20", "10.60.48.0/20"]
  data_subnet_cidrs    = ["10.60.64.0/24", "10.60.65.0/24", "10.60.66.0/24"]
  depends_on           = [terraform_data.deployment_gate]
}
module "eks" {
  source               = "./modules/eks"
  cluster_name         = local.cluster_name
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  kubernetes_version   = var.kubernetes_version
  addon_versions       = var.eks_addon_versions
  admin_principal_arns = var.eks_admin_principal_arns
  public_access_cidrs  = var.eks_public_access_cidrs
  depends_on           = [module.network]
}
module "backstage_database" {
  source                    = "./modules/rds-postgres"
  identifier                = "${var.resource_prefix}-backstage"
  vpc_id                    = module.network.vpc_id
  data_subnet_ids           = module.network.data_subnet_ids
  client_security_group_ids = { workers = module.eks.node_security_group_id }
  engine_version            = var.postgres_engine_version
  final_snapshot_suffix     = var.final_snapshot_suffix
}
module "ecr" {
  source           = "./modules/ecr"
  repository_names = toset(["${var.resource_prefix}/backstage", "${var.resource_prefix}/service-v0"])
  depends_on       = [terraform_data.deployment_gate]
}
module "portal_edge" {
  count                       = var.enable_portal_edge ? 1 : 0
  source                      = "./modules/portal-edge"
  resource_prefix             = var.resource_prefix
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.private_subnet_ids
  node_autoscaling_group_name = module.eks.node_autoscaling_group_name
  node_security_group_id      = module.eks.node_security_group_id
}
locals { cluster_name = "${var.resource_prefix}-eks" }
