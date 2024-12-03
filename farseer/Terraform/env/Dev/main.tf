# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use.
# Instead, use environment variables or IAM roles to manage credentials securely.
# Indicating Provider for Terraform to use
provider "aws" {
  access_key = var.aws_access_key # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key = var.aws_secret_key # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     = var.region         # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

module "Network" {
  source = "../../modules/Network" # Adjust to the path of your 'network' module
  environment             = var.environment
  vpc_cidr                = var.vpc_cidr             # Example CIDR block for dev
  azs                     = var.azs                  # One AZ for dev
  public_subnet_count     = var.public_subnet_count  # Number of public subnets for dev
  private_subnet_count    = var.private_subnet_count # Number of private subnets for dev
  nat_gateway_count       = var.nat_gateway_count    # Number of NAT gateways for dev
  auto_accept_peering     = var.auto_accept_peering # Adjust as per requirement
}

module "Compute" {
  source = "../modules/Compute"
  depends_on = [module.Network]
  environment               = var.environment
  key_name                  = var.key_name
  ec2_ami                   = var.ec2_ami
  instance_type             = var.instance_type
  bastion_count             = var.bastion_count # Number of bastion hosts
  frontend_count            = var.frontend_count # Number of frontend hosts
  backend_count             = var.backend_count # Number of backend hosts
  vpc_id                    = module.Network.vpc_id # VPC ID of created VPC for Env
  vpc_cidr                  = var.vpc_cidr         # VPC CIDR of created VPC for Env
  default_vpc_cidr_block    = module.Network.default_vpc_cidr_block # Default VPC CIDR Block
  public_subnet_ids         = module.Network.public_subnet_ids # List of public subnets created
  private_subnet_ids        = module.Network.private_subnet_ids # List of private subnets created
  user_data                 = var.user_data
}