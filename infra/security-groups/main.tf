variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "public_subnet_cidr_block" {}
variable "ec2_sg_name_for_python_api" {}

output "sg_ec2_sg_ssh_http_id" {
  value = aws_security_group.ec2_sg_ssh_http.id
}

output "rds_mysql_sg_id" {
  value = aws_security_group.rds_mysql_sg.id
}

output "sg_ec2_for_python_api" {
  value = aws_security_group.ec2_sg_python_api.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

# FIXED: Use name_prefix to avoid duplicate name conflicts
resource "aws_security_group" "ec2_sg_ssh_http" {
  name_prefix = "ec2-ssh-http-"  # CHANGED: Use prefix instead of fixed name
  description = "Enable SSH, HTTP, and HTTPS for EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "Allow HTTPS request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    description = "Allow all outgoing requests"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "EC2 Security Group - SSH, HTTP, HTTPS"
  }
}

# FIXED: Use name_prefix and remove circular dependency
resource "aws_security_group" "ec2_sg_python_api" {
  name_prefix = "ec2-python-api-"  # CHANGED: Use prefix instead of fixed name
  description = "Enable Port 5000 for Python API"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic on port 5000 from public subnets"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_block
  }

  ingress {
    description = "Allow direct access to port 5000 for testing"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "EC2 Python API Security Group - Port 5000"
  }
}

# ALB Security Group - this one is fine as-is
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic to EC2 Python API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_block
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ALB Security Group - HTTP/HTTPS"
  }
}

# FIXED: Remove circular dependency - use CIDR blocks only
resource "aws_security_group" "rds_mysql_sg" {
  name_prefix = "rds-mysql-sg-"  # CHANGED: Use prefix instead of fixed name
  description = "Allow MySQL access from EC2 instances"
  vpc_id      = var.vpc_id

  # FIXED: Only use CIDR blocks to avoid circular dependency
  ingress {
    description = "Allow MySQL from public subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_block
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "RDS MySQL Security Group"
  }
}