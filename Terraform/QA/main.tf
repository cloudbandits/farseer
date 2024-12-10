# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use.
# Instead, use environment variables or IAM roles to manage credentials securely.
# Indicating Provider for Terraform to use
provider "aws" {
  #  access_key = var.aws_access_key        # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  #  secret_key = var.aws_secret_key        # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region = var.region # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = [
      "eks", "get-token", "--cluster-name", module.eks.cluster_name
    ]
  }
}

resource "time_sleep" "wait_eks" {
  depends_on = [ module.eks ]
  create_duration = "60s"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "VPC" {
  source      = "./modules/VPC"
  environment = var.environment
  cidr_block  = var.cidr_block
}

# module "EC2" {
#   source            = "./modules/EC2"
#   environment       = var.environment
#   vpc_id            = module.VPC.vpc_id
#   ec2_ami           = var.ec2_ami
#   public_subnet_id1  = module.VPC.public_subnet_id1
#   public_subnet_id2  = module.VPC.public_subnet_id2
#   private_subnet_id1 = module.VPC.private_subnet_id1
#   private_subnet_id2 = module.VPC.private_subnet_id2
#   private_subnet_id3 = module.VPC.private_subnet_id3
#   private_subnet_id4 = module.VPC.private_subnet_id4
#   instance_type     = var.instance_type
#   key_name          = var.key_name
# }

# module ALB{
#     source= "./modules/ALB"
#     private_subnet_id1 = module.VPC.private_subnet_id1
#     private_subnet_id2 = module.VPC.private_subnet_id2
#     frontend1 = module.EC2.frontend1
#     frontend2 = module.EC2.frontend2
#     vpc_id = module.VPC.vpc_id
# }

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.environment}-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true
  enable_irsa = true

  vpc_id = module.VPC.vpc_id
  subnet_ids = [
    module.VPC.private_subnet_id1,
    module.VPC.private_subnet_id2,
    module.VPC.private_subnet_id3,
    module.VPC.private_subnet_id4
  ]
  eks_managed_node_groups = {
    default = {
      # https://www.middlewareinventory.com/blog/kubernetes-max-pods-per-node/
      instance_types = ["t3.micro"]
      min_size     = 1
      max_size     = 6
      desired_size = 4
    }
  }

  tags = {
    Name = "${var.environment}-eks-cluster"
  }
}

data "aws_caller_identity" "current" {}

# Create the IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name               = "aws-load-balancer-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${module.eks.cluster_oidc_issuer_url}"
        }
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${module.eks.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# Attach the IAM policy to the IAM Role
resource "aws_iam_policy_attachment" "aws_load_balancer_policy_attachment" {
  name       = "aws-load-balancer-policy-attachment"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
  roles      = [aws_iam_role.aws_load_balancer_controller_role.name]
}

# Create Kubernetes Service Account and Annotate with IAM Role ARN
# resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
#   depends_on = [ time_sleep.wait_eks ]
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller_role.arn
#     }
#   }
# }