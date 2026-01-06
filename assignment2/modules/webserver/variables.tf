variable "env_prefix" {
  type        = string
  description = "Environment prefix for naming resources"
}

variable "instance_name" {
  type        = string
  description = "Name of the EC2 instance"
}

variable "instance_suffix" {
  type        = string
  description = "Suffix to make resources unique"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where instance will be launched"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where instance will be launched"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the instance"
}

variable "public_key" {
  type        = string
  description = "Path to SSH public key"
}

variable "script_path" {
  type        = string
  description = "Path to user data script for instance"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
}
