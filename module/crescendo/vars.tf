# Project Name
variable "project-name" {
  description = "project name"
  type = string
}
# Tags
variable "tags_env" {
  description = "project environment"
  type = string
}

variable "tags_manage" {
    description = "managed by terraform"
    type = string
}

# Instance Type
variable "instance_type" {
  description   = "EC2 instance type"
  type          = string
}

# Public Key Pair
variable "pubkey" {
  description   = "public keypair"
  type          = string
}