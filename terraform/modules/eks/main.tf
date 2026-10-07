data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each = toset([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_node.name
  policy_arn = each.value
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Additional EKS control-plane security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-cluster"
  }
}

resource "aws_security_group" "eks_node" {
  name        = "${var.cluster_name}-node"
  description = "EKS worker-node and pod networking"
  vpc_id      = var.vpc_id

  tags = {
    Name                                        = "${var.cluster_name}-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes_https" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_node.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Worker nodes to EKS API"
}

resource "aws_vpc_security_group_egress_rule" "cluster_all" {
  security_group_id = aws_security_group.eks_cluster.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Control-plane egress"
}

resource "aws_vpc_security_group_ingress_rule" "node_self" {
  security_group_id            = aws_security_group.eks_node.id
  referenced_security_group_id = aws_security_group.eks_node.id
  ip_protocol                  = "-1"
  description                  = "Pod-to-pod and node-to-node traffic"
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cluster" {
  for_each = toset(["443", "4443", "6443", "8443", "9443", "10250", "15017"])

  security_group_id            = aws_security_group.eks_node.id
  referenced_security_group_id = aws_security_group.eks_cluster.id
  ip_protocol                  = "tcp"
  from_port                    = tonumber(each.value)
  to_port                      = tonumber(each.value)
  description                  = "EKS control plane and admission webhooks"
}

resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.eks_node.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Node egress through NAT"
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.cluster.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = length(var.public_access_cidrs) > 0
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_cloudwatch_log_group.eks
  ]
}

resource "aws_eks_access_entry" "admin" {
  for_each = var.admin_principal_arns

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = var.admin_principal_arns

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

resource "aws_launch_template" "eks_node" {
  name_prefix = "${var.cluster_name}-node-"

  vpc_security_group_ids = [
    aws_security_group.eks_node.id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version
  capacity_type   = "ON_DEMAND"
  instance_types  = var.node_instance_types
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    min_size     = var.node_min_size
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version
  }

  depends_on = [aws_iam_role_policy_attachment.eks_node]
}

resource "aws_eks_addon" "this" {
  for_each = var.addon_versions

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  # CoreDNS can otherwise be reported DEGRADED before the first node exists.
  depends_on = [aws_eks_node_group.default]
}


data "aws_partition" "current" {}
resource "aws_kms_key" "cluster" {
  description             = "EKS secrets for ${var.cluster_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "cluster" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.cluster.key_id
}
