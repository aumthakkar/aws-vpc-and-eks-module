
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${var.name_prefix}-lbc-iam-policy"
  path        = "/"
  description = "IAM Policy for the Load Balancer Controller"

  policy = data.http.lbc_iam_policy.response_body
}


resource "aws_iam_role" "lbc_iam_role" {
  name = "pht-dev-web-identity-role"

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
            "${local.aws_iam_openid_connect_provider_extract}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {

  policy_arn = aws_iam_policy.lbc_iam_policy.arn
  role       = aws_iam_role.lbc_iam_role.name
}


/*
The above role resource definition results in the following Trust Relationship on AWS

"Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::650251713601:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/0CA47DD6C4FEE341ECA523F7FE1A61FF"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.eu-north-1.amazonaws.com/id/0CA47DD6C4FEE341ECA523F7FE1A61FF:aud": "sts.amazonaws.com",
                    "oidc.eks.eu-north-1.amazonaws.com/id/0CA47DD6C4FEE341ECA523F7FE1A61FF:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"

*/