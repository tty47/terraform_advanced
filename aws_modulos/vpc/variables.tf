// VPC Variables
variable "vpc_name" {
  description = "vpc Name for tags"
  type        = string
}

variable "cidr_block" {
  description = "cidr_block"
  type        = string
}

variable "instance_tenancy" {
  description = "instance_tenancy, if you want your own infra"
  type        = string
  default     = "default"
}


// NETWORKS variables
variable "subnets" {
  description = "subnet_az_name"
  type        = list(map(string))
  default     = []
}