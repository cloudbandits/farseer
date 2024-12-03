variable "environment" {
  description = "Environment name (e.g., Dev, QA, Prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the environment"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "default_vpc_cidr_block" {
  description = "The CIDR block for the Default VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of subnet IDs (supports multi-AZ and single-AZ)"
}

variable "private_subnet_ids" {
  description = "List of subnet IDs (supports multi-AZ and single-AZ)"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "ec2_ami" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "Instance type for all EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "Variable to hold user data to insert into EC2 creation"
}

variable "bastion_count" {
  description = "Number of Bastion servers"
  type        = number
  default     = 1
}

variable "frontend_count" {
  description = "Number of Frontend servers"
  type        = number
  default     = 1
}

variable "backend_count" {
  description = "Number of Backend servers"
  type        = number
  default     = 1
}