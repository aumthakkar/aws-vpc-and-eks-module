resource "aws_iam_role" "efs_irsa_iam_role" {
  count = var.create_ebs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-efs-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_openid_connect_provider_extract}:aud" = "sts.amazonaws.com"
            "${local.aws_iam_openid_connect_provider_extract}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-efs-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEFSCSIDriverPolicy" {
  count = var.create_ebs_csi_driver ? 1 : 0

  role       = aws_iam_role.efs_irsa_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}