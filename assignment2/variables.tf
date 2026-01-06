variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for subnet"
}

variable "env_prefix" {
  type        = string
  description = "Environment prefix for naming resources"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "public_key" {
  type        = string
  description = "Public key path for SSH"
}

variable "private_key" {
  type        = string
  description = "Private key path for SSH"
}

variable "backend_servers" {
  type = list(object({
    name        = string
    script_path = string
  }))
  description = "Backend server definitions"
}

variable "my_ip" {
  type        = string
  description = "Your public IP for SSH access"
}
