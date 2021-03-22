provider "aws" {
  profile = "dev"
  region  = "ap-northeast-1"
}

module "storage" {
  source = "./storage"
}


module "network" {
  source = "./network"
  s3_log = module.storage.s3_log
}

module "container" {
  source           = "./container"
  vpc              = module.network.vpc
  private_subnet_0 = module.network.private_subnet_0
  private_subnet_1 = module.network.private_subnet_1
  lb_target_group  = module.network.lb_target_group
}
