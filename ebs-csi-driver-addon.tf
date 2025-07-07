
data "aws_eks_addon_version" "ebs_latest_driver" {
  addon_name = "aws-ebs-csi-driver"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count      = var.create_ebs_csi_driver ? 1 : 0
  depends_on = [aws_eks_node_group.my_eks_public_nodegroup, aws_eks_node_group.my_eks_private_nodegroup]

  cluster_name = aws_eks_cluster.my_eks_cluster.id
  addon_name   = "aws-ebs-csi-driver"

  addon_version               = data.aws_eks_addon_version.ebs_latest_driver.version
  configuration_values        = null
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = null # Optional so if not found here then it will use permissions from Node IAM Role

}

