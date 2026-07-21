resource "aws_iam_role" "my_ebs_csi_iam_role" {
  count = var.create_ebs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-ebs-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "EBSCSIIAMRole"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-ebs-csi-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEBSCSIDriverPolicy" {
  count = var.create_ebs_csi_driver ? 1 : 0

  role       = aws_iam_role.my_ebs_csi_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}





