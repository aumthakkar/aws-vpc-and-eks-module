
resource "aws_iam_role" "my_cloudwatch_iam_role" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  name = "${var.name_prefix}-cloudwatch-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "CloudWatchIAMRole"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-cloudwatch-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_CloudWatchAgentServerPolicy" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  role       = aws_iam_role.my_cloudwatch_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

# Attaching XRay policy to automatically discover & monitor application performance (Uses CW app signals which uses OT)
resource "aws_iam_role_policy_attachment" "eks_AWSXrayWriteOnlyAccess" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  role       = aws_iam_role.my_cloudwatch_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"

}
