output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "node_security_group_id" { value = aws_security_group.eks_node.id }
output "node_autoscaling_group_name" { value = aws_eks_node_group.default.resources[0].autoscaling_groups[0].name }
