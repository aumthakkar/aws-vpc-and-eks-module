

## Usage:

```terraform
module "eks_cluster" {
  source = "github.com/aumthakkar/aws-eks-module.git"

  name_prefix     = local.name
  aws_region  = "eu-north-1"

  # vpc networking related values

  vpc_cidr = "10.0.0.0/16"

  auto_create_subnet_addresses = true

  public_subnet_count           = 2
  public_subnet_cidr_addresses  = var.public_subnet_cidr_addresses
  private_subnet_count          = 2
  private_subnet_cidr_addresses = var.private_subnet_cidr_addresses

  cluster_public_security_groups_name = "pht-dev-cluster-public-sg"
  cluster_public_security_groups_desc = "pht-dev eks cluster public security group"  
  ssh_access_ips                      = var.ssh_access_ips

  cluster_efs_security_group_name = "pht-dev-cluster-efs-sg"
  cluster_efs_security_group_desc = "pht-dev eks cluster EFS security group"

  # eks-cluster related values
  cluster_name        = "pht-dev-eksdemo"
  eks_cluster_version = "1.32"

  cluster_service_ipv4_cidr            = "172.20.0.0/16"
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_public_nodegroup_name       = "pht-dev-public-nodegroup"
  public_nodegroup_ami_type       = "BOTTLEROCKET_ARM_64"
  public_nodegroup_capacity_type  = "ON_DEMAND"
  public_nodegroup_disk_size      = 20
  public_nodegroup_instance_types = ["t3.large"]

  public_nodegroup_desired_size       = 1
  public_nodegroup_max_size           = 2
  public_nodegroup_min_size           = 1
  public_nodegroup_max_unavail_pctage = 50

  eks_private_nodegroup_name       = "pht-dev-private-nodegroup
  private_nodegroup_ami_type       = "BOTTLEROCKET_ARM_64"
  private_nodegroup_capacity_type  = "ON_DEMAND"
  private_nodegroup_disk_size      = 20
  private_nodegroup_instance_types = ["t3.large"]

  private_nodegroup_desired_size       = 1
  private_nodegroup_max_size           = 2
  private_nodegroup_min_size           = 1
  private_nodegroup_max_unavail_pctage = 50

}

```

## Description

-    This module creates an AWS VPC in which it also creates an EKS cluster with EBS driver, EFS driver EKS     
     addons and a Load Balancer Ingress Controller. 
-    Based on the count of the number of subnets selected by the user, it can conditonally, automatically create  
     these subnets along with their IP addresses using the cidrsubnet() based on the VPC CIDR block selected. 
     -    If the user needs to use the subnet IP addresses of their choice within the VPC CIDR range, then those subnet IP addresses can be manually added in the variables/*.tfvars file in the root module by opting to provide a value of "false" to the auto_create_subnet_addresses argument of the root module.
-    These subnets are created in the automatically selected and shuffled Availability Zones. 
-    This module also creates an Ingress Class with the controller as the Application Load Balancer. 

## Requirements

| Name       | Version      |
| :--------- | :----------- |
| terraform  | >= 1.0.0     |
| aws        | >= 5.9       |
| kubernetes | >= 2.7       |
| helm       | >= 3.0.0-pre2|
| http       | >= 3.5       |

## Inputs

| Name                                 | Type         | Description                                                                                                                   |
| :----------------------------------- | :----------- | :---------------------------------------------------------------------------------------------------------------------------- |
| name_prefix                          | string       | Name prefix to assign for your resource names.                                                                                |
|                                      |              |                                                                                                                               |
| # VPC related Inputs                 |              |                                                                                                                               |
| aws_region                           | string       | The AWS region for your VPC.                                                                                                  |
| vpc_cidr                             | string       | The VPC_CIDR of your setup.                                                                                                   |
| auto_create_subnet_addresses         | boolean      | To decide whether to automatically create subnet IP addresses.                                                                |
| public_subnet_count                  | number       | Number of public subnets to create.                                                                                           |
| public_subnet_cidr_addresses         | string       | To be entered manually if auto_create_subnet_addresses is set to false.                                                       |
| private_subnet_count                 | number       | Number of private subnets to create.                                                                                          |
| private_subnet_cidr_addresses        | string       | To be entered manually if auto_create_subnet_addresses is set to false.                                                       |
| cluster_public_security_groups_name  | string       | Public Security Groups name.                                                                                                  |
| cluster_public_security_groups_desc  | string       | Public Security Groups description.                                                                                           |
| ssh_access_ips                       | string       | IP address CIDR block defined in Inboundaddresses to the public security group.                                               |
| cluster_efs_security_group_name      | string       | EFS security group name of your cluster.                                                                                      |
| cluster_efs_security_group_desc      | string       | EFS security group description of your cluster.                                                                               |
|                                      |              |                                                                                                                               |
| # EKS Cluster related Inputs         |              |                                                                                                                               |
| cluster_name                         | string       | EKS Cluster name.                                                                                                             |
| eks_cluster_version                  | string       | EKS Cluster version to be created.                                                                                            |
| cluster_service_ipv4_cidr            | string       | The CIDR block to assign Kubernetes pod and service IP addresses from.                                                        |
| cluster_endpoint_private_access      | boolean      | Whether the Amazon EKS private API server endpoint is enabled.                                                                |
| cluster_endpoint_public_access       | boolean      | Whether the Amazon EKS private API server endpoint is enabled.                                                                |
| cluster_endpoint_public_access_cidrs | list(string) | Indicates which list of CIDR blocks can access EKS public API aerver endpoint when enabled. EKS defaults this to "0.0.0.0/0". |
|                                      |              |                                                                                                                               |
| # EKS nodegroup related inputs       |              |                                                                                                                               |
| eks_public_nodegroup_name            | string       | Name assigned to your EKS public nodegroup.                                                                                   |
| public_nodegroup_ami_type            | string       | AMI type of the nodegroup worker node instances.                                                                              |
| public_nodegroup_capacity_type       | string       | Type of capacity of the Node group instances. Valid values - ON_DEMAND, SPOT.                                                 |
| public_nodegroup_disk_size           | number       | Disk size in GiB for worker nodes. Defaults to 50 for Windows and 20 for all other node groups.                               |
| public_nodegroup_instance_types      | string       | List of instance types associated wih the Node groups Defaults to "t3.medium".                                                |
|                                      |              |                                                                                                                               |
| public_nodegroup_desired_size        | number       | Desired number of worker nodes.                                                                                               |
| public_nodegroup_max_size            | number       | Maximum number of worker nodes.                                                                                               |
| public_nodegroup_mix_size            | number       | Minimum number of worker nodes                                                                                                |
| public_node_max_unavail_pctage       | number       | Desired max percentage of unavailable worker nodes during group update                                                        |
|                                      |              |                                                                                                                               |
| eks_private_nodegroup_name           | string       | Name assigned to your EKS private nodegroup.                                                                                  |
| private_nodegroup_ami_type           | string       | AMI type of the nodegroup worker node instances.                                                                              |
| private_nodegroup_capacity_type      | string       | Type of capacity of the Node group instances. Valid values - ON_DEMAND, SPOT.                                                 |
| private_nodegroup_disk_size          | number       | Disk size in GiB for worker nodes. Defaults to 50 for Windows and 20 for all other node groups.                               |
| private_nodegroup_instance_types     | string       | List of instance types associated wih the Node groups Defaults to "t3.medium".                                                |
|                                      |              |                                                                                                                               |
| private_nodegroup_desired_size       | number       | Desired number of worker nodes.                                                                                               |
| private_nodegroup_max_size           | number       | Maximum number of worker nodes.                                                                                               |
| private_nodegroup_mix_size           | number       | Minimum number of worker nodes                                                                                                |
| private_node_max_unavail_pctage      | number       | Desired max percentage of unavailable worker nodes during group update                                                        |

## Resources

| Name                                               | Type        | Description                                                                                                                                                                                       |
| :------------------------------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| # VPC Resources                                    |             |                                                                                                                                                                                                   |
| aws_vpc.my_eks_vpc                                 | resource    | AWS VPC                                                                                                                                                                                           |
| aws_availability_zones.aailable                    | data source | Data source to get all the possible AZ s from an AWS region                                                                                                                                       |
| aws_subnet.pht_public_subnets                      | resource    | Public Subnets of the VPC                                                                                                                                                                         |
| aws_route_table.public_route_table                 | resource    | Public Route Table                                                                                                                                                                                |
| aws_internet_gateway.my_igw                        | resource    | Internet Gateway                                                                                                                                                                                  |
| aws_subnet.pht_private_subnets                     | resource    | Private Subnets                                                                                                                                                                                   |
| aws_default_route_tabledefault_private_route_table | resource    | Default Private Route Table                                                                                                                                                                       |
| aws_route_table.private_route_table                | resource    | Private Route Table                                                                                                                                                                               |
| aws_eip.nat_gw_eip                                 | resource    | NAT Gateway Elastic IP                                                                                                                                                                            |
| aws_nat_gateway.my_nat_gateway                     | resource    | NAT Gateway                                                                                                                                                                                       |
| aws_security_group.cluster_sg                      | resource    | AWS EKS Cluster Security Group                                                                                                                                                                    |
|                                                    |             |                                                                                                                                                                                                   |
| # EKS Cluster Resources                            |             |                                                                                                                                                                                                   |
| aws_iam_role.eks_master_role                       | resource    | AWS EKS Master IAM role with AmazonEKSClusterPolicy and AmazonEKSVPCResourceController IAM Policies attached                                                                                      |
| aws_iam_role.eks_nodegroup_role                    | resource    | AWS EKS Node Group IAM role with AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy and AmazonEFSCSIDriverPolicy IAM Policies attached |
| aws_iam_openid_connect_provider.oidc_provider      | resource    | AWS IAM OpenId Connect Provider                                                                                                                                                                   |
| http.lbc_iam_policy                                | data source | Load Balancer IAM policy                                                                                                                                                                          |
| aws_iam_role.lbc_iam_role                          | resource    | Load Balancer IAM role with an action of AssumeRolewithWebIdentity for the AWS IAM OIDC Provider Principal                                                                                        |
| aws_eks_cluster.my_eks_cluster                     | resource    | AWS EKS cluster                                                                                                                                                                                   |
| aws_eks_node_group.my_eks_public_nodegroup         | resource    | Public EKS Node Group                                                                                                                                                                             |
| aws_eks_node_group.my_eks_private_nodegroup        | resource    | Private Node Group                                                                                                                                                                                |
| aws_eks_addon.aws_ebs_csi_driver                   | resource    | EKS Addon for EBS CSI Driver                                                                                                                                                                      |
| aws_eks_addon.aws_efs_csi_driver                   | resource    | EKS Addon for EFS CSI Driver                                                                                                                                                                      |
| helm_release.lb_controller                         | resource    | Helm release to install the Load Balancer Controller                                                                                                                                              |


## Outputs

| Name                                             | Type         | Description                                                                                                                                                     |
| :----------------------------------------------- | :----------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| # VPC related Outputs                            |              |                                                                                                                                                                 |
| vpc_id                                           | string       | VPC identifier.                                                                                                                                                 |
| public_subnets                                   | list(string) | List of public subnets.                                                                                                                                         |
| private_subnets                                  | list(string) | List of private subnets.                                                                                                                                        |
| vpc_cidr                                         | string       | VPC CIDR block.                                                                                                                                                 |
| public_sg_ids                                    | list(string) | List of Public Security Group Ids.                                                                                                                              |
| efs_sg_ids                                       | list(string) | Lit of EFS Security Group Ids.                                                                                                                                  |
| igw_id                                           | string       | Internet Gateway ID.                                                                                                                                            |
| lbc_helm_metadata                                | list(object) | Metadata block outlining the status of the deployed release.                                                                                                    |
|                                                  |              |                                                                                                                                                                 |
| #EKS Cluster related Outputs                     |              |                                                                                                                                                                 |
| cluster_id                                       | string       | The name/id of the EKS cluster.                                                                                                                                 |
| cluster_endpoint                                 | string       | The endpoint of your EKS Kubernetes API.                                                                                                                        |
| cluster_arn                                      | string       | The ARN of the EKS cluster.                                                                                                                                     |
| cluster_cert_auth_data                           | string       | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_verion                                   | string       | The Kubernetes server version for the EKS cluster.                                                                                                              |
| cluster_security_group_id                        | list         | EKS cluster security group id.                                                                                                                                  |
| cluster_iam_role_name                            | string       | IAM role ARN of the EKS cluster.                                                                                                                                |
| cluster_oidc_issuer_url                          | string       | The URL on the EKS cluster OIDC Issuer.                                                                                                                         |
| cluster_primary_security_group_id                | string       | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console.                  |
| node_group_public_id                             | string       | Public Node Group ID.                                                                                                                                           |
| node_group_public_arn                            | string       | Public Node Group ARN.                                                                                                                                          |
| node_group_public_status                         | string       | Public Node Group status                                                                                                                                        |
| node_group_public_version                        | string       | Public Node Group Kubernetes Version                                                                                                                            |
| node_group_private_id                            | string       | Private Node Group ID.                                                                                                                                          |
| node_group_private_arn                           | string       | Private Node Group ARN.                                                                                                                                         |
| node_group_private_status                        | string       | Private Node Group status.                                                                                                                                      |
| node_group_private_version                       | string       | Private Node Group Kubernetes Version.                                                                                                                          |
| # EKS IRSA related Outputs                       |              |                                                                                                                                                                 |
| aws_iam_openid_connect_provider_arn              | string       | OpenId Connect Provider ARN.                                                                                                                                    |
| aws_iam_openid_connect_provider_extract_from_arn | string       | Extract of the OIDC Id part from the OpenId Connect Provider ARN                                                                                                |
| # EKS-EBS-CSI-Addon related Outputs              |              |                                                                                                                                                                 |
| ebs_eks_addon_arn                                | string       | EBS CSI driver ARN                                                                                                                                              |
| ebs_eks_addon_id                                 | string       | EBS CSI driver Id                                                                                                                                               |
| # EKS-EFS-CSI-Addon related Outputs              |              |                                                                                                                                                                 |
| efs_eks_addon_arn                                | string       |                                                                                                                                                                 |
| efs_eks_addon_id                                 | string       |                                                                                                                                                                 |




