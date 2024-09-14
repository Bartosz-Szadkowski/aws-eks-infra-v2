variable "vpc_id" {
  description = "The ID of the VPC where the bastion host will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the public subnet where the bastion host will be placed"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "bastion_ami" {
  description = "The AMI ID for the bastion host"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for accessing the bastion host"
  type        = string
}

variable "admin_ip" {
  description = "The IP address from which SSH access is allowed"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}
