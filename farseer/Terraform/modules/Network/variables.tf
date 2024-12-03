##################################################
### VPC VARIABLES ###
##################################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

##################################################
### GATEWAY VARIABLES ###
##################################################

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create."
  type        = number
}

##################################################
### SUBNET VARIABLES ###
##################################################

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
}

variable "azs" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

##################################################
### VPC PEERING VARIABLES ###
##################################################

variable "auto_accept_peering" {
  description = "Whether to automatically accept VPC peering (true/false)"
  type        = bool
}

# variable "peer_region" {
#   description = "Region of the peer VPC (optional, used for future potential)"
#   type        = string
#   default     = ""
# }

##################################################
### DEFAULT/OPS VPC VARIABLES ###
##################################################

# None at the moment