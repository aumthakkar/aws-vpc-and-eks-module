# === eks/eks-cluster-iamrole.tf ===

resource "aws_iam_role" "eks_master_role" {
  name = "eks_master_role"

  # Terraform's "jsonencode" function converts a tf expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "eks-master-role"
  }
}

# Associate the above IAM role to both the AWS managed EKS IAM policies below

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}