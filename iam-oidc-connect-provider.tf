data "aws_partition" "default" {}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer

  client_id_list = ["sts.${data.aws_partition.default.dns_suffix}"] # This is the audience for our OIDC provider

  # Thumbprint of the root CA cert of the EKS cluster
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # This value won't change till 2037 hence hardcoding it here itself 

}