output "cluster_name" { value = module.eks.cluster_name }
output "vpc_id" { value = module.network.vpc_id }
output "data_subnet_ids" { value = module.network.data_subnet_ids }
output "backstage_database_endpoint" { value = module.backstage_database.endpoint }
output "backstage_master_secret_arn" { value = module.backstage_database.master_secret_arn }
output "ecr_repository_urls" { value = module.ecr.repository_urls }
output "portal_url" { value = try(module.portal_edge[0].api_gateway_url, null) }
