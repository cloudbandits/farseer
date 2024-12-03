##################################################
### VARIABLES ###
##################################################

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_name" {
  description = "Name for the Load Balancer Security Group"
  type        = string
}

variable "target_group_name" {
  description = "Name for the Target Group"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "target_instance_ids" {
  description = "List of instance IDs to attach to the ALB target group"
  type        = list(string)
}