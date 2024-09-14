variable "vpc_id" {
  description = "The ID of the VPC where the bastion host will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the public subnet where the bastion host will be placed"
  type        = string
}

# variable "vpc_cidr" {
#   description = "The CIDR block of the VPC"
#   type        = string
# }

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}