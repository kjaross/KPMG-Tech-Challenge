module "vpc" {
  source = "modules\/vpc"
}

module "security" {
  source = "modules\/security"
  vpc_id = module.vpc.vpc_id    #gets the value from the above module "vpc" "vpc_id" - is the value in the output
  #you also need to declare "vpc_id" as a variable in the module variables.tf
}

module "application" {
  source = "modules\/application"
  elb_sg = module.security.security_group_id_elb
  web_sg = module.security.security_group_id_web
  vpc_id = module.vpc.vpc_id
}
