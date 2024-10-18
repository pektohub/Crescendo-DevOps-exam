
module "crescendo" {
  source = "./module/crescendo"

  project-name      = var.project-name
  tags_env          = var.tags_env
  tags_manage       = var.tags_manage
  # vpc_cidr_block    = var.vpc_cidr_block
  # pubnet_cidr_block = var.pubnet_cidr_block
  # prinet_cidr_block = var.prinet_cidr_block
  instance_type     = var.instance_type
  pubkey            = var.pubkey
}