# Project Name
variable "project-name" {
  description = "project name"
  type        = string
}
# Tags
variable "tags_env" {
  description = "project environment"
  type        = string
}

variable "tags_manage" {
  description = "managed by terraform"
  type        = string
}
# VPC CIDR_Block
variable "vpc_cidr_block" {
  description = "vpc cidr_block"
  type        = string
}

# Subnet CIDR_BLOCK 
variable "pubnet_cidr_block" {
  description = "public subnet cidr block"
  type        = list(string)
}

variable "prinet_cidr_block" {
  description = "private subnet cidr block"
  type        = list(string)
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# Public Key Pair
variable "pubkey" {
  description = "public keypair"
  type        = string
}