##################################################
### SSH KEY ###
##################################################

# Generate a new SSH key pair (optional, if no public key is provided)
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the AWS Key Pair
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.generated_key.public_key_openssh
}

# Save the private key locally (for generated key pairs only)
resource "local_file" "save_private_key" {
  content  = tls_private_key.generated_key.private_key_pem
  filename = "/home/ubuntu/.ssh/${var.key_name}.pem" # Use the key name for better organization
}

##################################################
### EC2 INSTANCES ###
##################################################

# Bastion Instances
resource "aws_instance" "bastion" {
  count         = var.bastion_count
  ami           = var.ec2_ami
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)] # Distribute across public subnets
  key_name      = var.key_name
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name        = "${var.environment}-bastion-${count.index + 1}"
    Environment = var.environment
  }
  depends_on = [
    var.public_subnet_ids
  ]
}

# Frontend Instances
resource "aws_instance" "frontend" {
  count         = var.frontend_count
  ami           = var.ec2_ami
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index % length(var.private_subnet_ids)] # Distribute across private subnets
  key_name      = var.key_name
  security_groups = [aws_security_group.frontend_sg.id]

  tags = {
    Name        = "${var.environment}-frontend-${count.index + 1}"
    Environment = var.environment
  }
  depends_on = [
    var.private_subnet_ids
  ]
}

# Backend Instances
resource "aws_instance" "backend" {
  count         = var.backend_count
  ami           = var.ec2_ami
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index % length(var.private_subnet_ids)] # Distribute across private subnets
  key_name      = var.key_name
  security_groups = [aws_security_group.backend_sg.id]
  user_data = var.user_data

  tags = {
    Name        = "${var.environment}-backend-${count.index + 1}"
    Environment = var.environment
  }
  depends_on = [
    var.private_subnet_ids
  ]
}

##################################################
### SECURITY GROUPS ###
##################################################

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Security Group for Bastion Hosts"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "${var.environment}-frontend-sg"
  description = "Security Group for Frontend Servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.default_vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend Security Group
resource "aws_security_group" "backend_sg" {
  name        = "${var.environment}-backend-sg"
  description = "Security Group for Backend Servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.default_vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}