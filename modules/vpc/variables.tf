variable "cidr_block" {}

variable "tags" {
  type        = map(string)
  default     = {
    Terraform = "true"
    Environment = "dev"
  }
}