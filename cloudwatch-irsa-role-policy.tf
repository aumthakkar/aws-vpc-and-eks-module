resource "aws_iam_role" "cloudwatch_irsa_role" {
  name = "${var.name_prefix}-cloudwatch-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"

        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        }

        Condition = {
          StringEquals = {
            "${local.aws_iam_openid_connect_provider_extract}:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "${local.aws_iam_openid_connect_provider_extract}:sub" = [
              "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent",
              "system:serviceaccount:amazon-cloudwatch:fluent-bit"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-cloudwatch-irsa-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks-CloudWatchAgentServerPolicy" {
  count = var.create_cloudwatch_observability_and_fluentbit_agents ? 1 : 0

  role       = aws_iam_role.cloudwatch_irsa_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}