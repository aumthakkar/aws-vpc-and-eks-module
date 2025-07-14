# Resource: Create External DNS IAM Policy 
resource "aws_iam_policy" "external_dns_iam_policy" {
  count = var.create_external_dns_controller ? 1 : 0

  name        = "pht-dev-AllowExternalDNSUpdates"
  path        = "/"
  description = "External DNS IAM Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })

  tags = {
    tag-key = "Allow-External-DNS-Updates"
  }
}


# Resource: Create IAM Role 
resource "aws_iam_role" "ext_dns_iam_role" {
  count = var.create_external_dns_controller ? 1 : 0

  name = "pht-dev-ext-dns-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}" # Replace with your OIDC provider ARN
          # You can further limit by Condition arg (e.g., web-identity-token)
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_openid_connect_provider_extract}:aud" : "sts.amazonaws.com",
            "${local.aws_iam_openid_connect_provider_extract}:sub" : "system:serviceaccount:default:external-dns"
          }
        }
      }
    ]
  })
}

# Associate External DNS IAM Policy with IAM Role
resource "aws_iam_role_policy_attachment" "externaldns_iam_role_policy_attachment" {
  count = var.create_external_dns_controller ? 1 : 0

  policy_arn = aws_iam_policy.external_dns_iam_policy[count.index].arn
  role       = aws_iam_role.ext_dns_iam_role[count.index].name
}



