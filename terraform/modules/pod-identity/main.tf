data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = [var.namespace]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = [var.service_account]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks-cluster-name"
      values   = [var.cluster_name]
    }
  }
}
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}
resource "aws_iam_role_policy" "this" {
  name   = "controller-access"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}
resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
}
