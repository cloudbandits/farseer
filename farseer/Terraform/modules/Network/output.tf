##################################################
### VPC OUTPUTS ###
##################################################

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "default_vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
  description = "The CIDR block of the Default VPC"
}

##################################################
### GATEWAY OUTPUTS ###
##################################################

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_eips" {
  description = "The Elastic IPs associated with the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

##################################################
### SUBNETS OUTPUTS ###
##################################################

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

##################################################
### ROUTE TABLES OUTPUTS ###
##################################################

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

##################################################
### VPC PEERING OUTPUTS ###
##################################################

output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.main.id
}

output "peering_public_route_ids" {
  description = "The route IDs for the peering connection in the public route tables"
  value       = aws_route.peering_public[*].id
}

output "peering_private_route_ids" {
  description = "The route IDs for the peering connection in the private route tables"
  value       = aws_route.peering_private[*].id
}

output "peering_default_route_id" {
  description = "The route ID for the peering connection in the default route table"
  value       = aws_route.peering_default.id
}