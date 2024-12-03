##################################################
### ENVIRONMENT VARIABLES ###
##################################################

variable "environment" {
  description = "The environment for this configuration (e.g., dev, qa, prod)"
  type        = string
}

variable aws_access_key{
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable aws_secret_key{
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

##################################################
### NETWORK VARIABLES ###
##################################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "A list of availability zones for the VPC"
  type        = list(string)
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
}

variable "public_subnet_ids" {
  description = "List of subnet IDs (supports multi-AZ and single-AZ)"
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
}

variable "private_subnet_ids" {
  description = "List of subnet IDs (supports multi-AZ and single-AZ)"
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways"
  type        = number
}

variable "auto_accept_peering" {
  description = "Whether to automatically accept VPC peering connections"
  type        = bool
}

##################################################
### COMPUTE VARIABLES ###
##################################################
variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "ec2_ami" {
  description = "AMI for EC2 instances"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "user_data" {
  description = "Variable to hold user data to insert into EC2 creation"
}

variable "bastion_count" {
  description = "Number of Bastion instances"
  default     = 1
}

variable "frontend_count" {
  description = "Number of frontend instances"
  default     = 1
}

variable "backend_count" {
  description = "Number of backend instances"
  default     = 1
}