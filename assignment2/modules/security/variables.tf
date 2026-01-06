variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix for naming and tagging"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address with /32 for SSH access"
  type        = string
}
