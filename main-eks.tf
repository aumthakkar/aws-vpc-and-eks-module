

# === eks_cluster related /main.tf ====

resource "aws_eks_cluster" "my_eks_cluster" {
  name = var.cluster_name

  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = aws_subnet.pht_private_subnets[*].id
    # subnet_ids = aws_subnet.pht_public_subnets[*].id  (# If you need to install the EKS cluster in public subnets)

    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access

    public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr # "172.20.0.0/16"
  }

  # Enable EKS Cluster Control Plane Logging

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController
  ]
}

# EKS Node Group Config follows:
# Public Node Group 

resource "aws_eks_node_group" "my_eks_public_nodegroup" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = var.eks_public_nodegroup_name
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = aws_subnet.pht_public_subnets[*].id

  scaling_config {
    desired_size = var.public_nodegroup_desired_size
    max_size     = var.public_nodegroup_max_size
    min_size     = var.public_nodegroup_min_size
  }

  ami_type       = var.public_nodegroup_ami_type
  capacity_type  = var.public_nodegroup_capacity_type
  disk_size      = var.public_nodegroup_disk_size
  instance_types = var.public_nodegroup_instance_types

  # remote_access {
  #   ec2_ssh_key = var.public_nodegroup_key_name
  # }

  update_config {
    # max_unavailable = 1 You can use this one or the one below
    max_unavailable_percentage = var.public_nodegroup_max_unavail_pctage
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-AmazonEBSCSIDriverPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEFSCSIDriverPolicy,
    aws_iam_role_policy_attachment.eks-CloudWatchAgentServerPolicy
  ]

  tags = {
    Name = "${var.name_prefix}-public-eks-node-group"
  }
}



# Private Node Group 

resource "aws_eks_node_group" "my_eks_private_nodegroup" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = var.eks_private_nodegroup_name
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = aws_subnet.pht_private_subnets[*].id

  scaling_config {
    desired_size = var.private_nodegroup_desired_size
    max_size     = var.private_nodegroup_desired_size
    min_size     = var.private_nodegroup_desired_size
  }

  ami_type       = var.private_nodegroup_ami_type
  capacity_type  = var.private_nodegroup_capacity_type
  disk_size      = var.private_nodegroup_disk_size
  instance_types = var.private_nodegroup_instance_types

  # remote_access {
  #   ec2_ssh_key = var.private_nodegroup_key_name
  # }

  update_config {
    # max_unavailable = 1 Use any one of these 2
    max_unavailable_percentage = var.private_nodegroup_max_unavail_pctage
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-AmazonEBSCSIDriverPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEFSCSIDriverPolicy,
    aws_iam_role_policy_attachment.eks-CloudWatchAgentServerPolicy
  ]

  tags = {
    Name = "${var.name_prefix}-private-eks-node-group"
  }
}



