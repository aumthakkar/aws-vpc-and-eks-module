
data "aws_eks_addon_version" "ebs_csi_driver_latest" {
  addon_name = "aws-ebs-csi-driver"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "my_ebs_csi_driver" {
  count = var.create_ebs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace_config {
    namespace = "kube-system"
  }

  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_driver_latest.version

  pod_identity_association {
    role_arn        = aws_iam_role.my_ebs_csi_iam_role[count.index].arn
    service_account = "ebs-csi-controller-sa"
  }

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = null

  tags = {
    Name = "${var.name_prefix}-ebs-csi-driver"
  }

  depends_on = [
    aws_eks_addon.my_eks_pod_identity_agent,
    aws_eks_node_group.my_eks_public_nodegroup,
    aws_eks_node_group.my_eks_private_nodegroup
  ]
}

