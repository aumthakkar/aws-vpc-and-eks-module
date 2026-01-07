

data "aws_eks_addon_version" "cw_observability_latest_driver" {
  addon_name = "amazon-cloudwatch-observability"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "amazon_cloudwatch_observability_addon" {
  count = var.create_cloudwatch_observability_and_fluentbit_agents ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.id
  addon_name   = "amazon-cloudwatch-observability"

  addon_version               = data.aws_eks_addon_version.cw_observability_latest_driver.version
  configuration_values        = null
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = null # Optional so if not found here then it will use permissions from Node IAM Role

  depends_on = [
    aws_eks_node_group.my_eks_public_nodegroup,
    aws_eks_node_group.my_eks_private_nodegroup,
    aws_iam_role_policy_attachment.eks-CloudWatchAgentServerPolicy
  ]

}