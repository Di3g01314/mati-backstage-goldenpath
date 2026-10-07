mock_provider "aws" {}
run "isolated_data_and_private_workers" {
  command = plan
  module { source = "./modules/network" }
  variables {
    resource_prefix      = "goldenpath-test"
    cluster_name         = "goldenpath-test-eks"
    vpc_cidr             = "10.60.0.0/16"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.60.0.0/24", "10.60.1.0/24"]
    private_subnet_cidrs = ["10.60.16.0/20", "10.60.32.0/20"]
    data_subnet_cidrs    = ["10.60.64.0/24", "10.60.65.0/24"]
  }
  assert {
    condition     = length(aws_route_table.data.route) == 0
    error_message = "Database subnet route table must have no Internet or NAT route."
  }
  assert {
    condition     = alltrue([for subnet in aws_subnet.private : !subnet.map_public_ip_on_launch]) && alltrue([for subnet in aws_subnet.data : !subnet.map_public_ip_on_launch])
    error_message = "Workers and database subnets must not assign public IPs."
  }
}
