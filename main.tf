#--------------------------------------------------------------
# Initialize module should run before applying terraform init-backend
#--------------------------------------------------------------

module "initialize" {
  source = "./initialize/"

  environment_code    = var.environment_code
  owner_technical     = var.owner_technical
  owner_business      = var.owner_business
  organization_prefix = var.organization_prefix
  region              = var.region
  purpose_application = "terraform"
  purpose_tier        = "private"
  description         = "s3 bucket to store remote state of terraform"
}
module "vpc" {
  source            = "../modules/vpc"
  vpc_cidr_block    = var.vpc_cidr_block
  environment_code  = var.environment_code
  region_code       = var.region_code
  owner_technical   = var.owner_technical
  owner_business    = var.owner_business
  region            = var.region
  azs               = var.azs
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  protected_subnets = var.protected_subnets
}

module "nacl" {
  source            = "../modules/nacl"
  vpc_id            = module.vpc.id
  environment_code  = var.environment_code
  region_code       = var.region_code
  owner_technical   = var.owner_technical
  owner_business    = var.owner_business
  public_subnets    = module.vpc.public_subnets
  private_subnets   = module.vpc.private_subnets
  protected_subnets = module.vpc.protected_subnets
}
module "security-group" {
  source           = "../modules/security-group"
  vpc_id           = module.vpc.id
  environment_code = "test"
  region_code      = var.region_code
  owner_technical  = var.owner_technical
  owner_business   = var.owner_business
}
module "autoscaling" {
  source             = "../modules/autoscaling"
  environment_code   = var.environment_code
  owner_technical    = var.owner_technical
  owner_business     = var.owner_business
  vpc_id             = module.vpc.id
  public_subnets     = ["subnet-4184602a", "subnet-da58c4a1"]
  region_code        = var.region_code
  ec2_profile_name   = module.roles.ec2_profile_name
  node_ami_id        = var.node_ami_id
  node_id            = module.security-groups.app_id
  min_size           = var.api_min_size
  max_size           = var.api_max_size
  key_name           = var.key_name
  region             = var.region
  node_instance_type = var.node_instance_type
}
module "alb" {
  source              = "../modules/alb"
  environment_code    = "test"
  owner_technical     = var.owner_technical
  owner_business      = var.owner_business
  public_subnets      = module.vpc.public_subnets
  region_code         = var.region_code
  region              = var.region
  elb_id              = module.security-groups.elb_id
  vpc_id              = module.vpc.id
  organization_prefix = var.organization_prefix
  tld                 = var.tld
#  acm_certificate_arn = module.acm.acm_certificate_arn
}
module "vpn" {
  source           = "../modules/vpn"
  environment_code = var.environment_code
  owner_technical  = var.owner_technical
  owner_business   = var.owner_business
  //  organization_prefix = var.organization_prefix
  public_subnets    = module.vpc.public_subnets
  vpn_id            = module.security-groups.vpn_id
  key_name          = var.key_name
  region            = var.region
  region_code       = var.region_code
  vpc_id            = module.vpc.id
#  vpn_ami           = "ami-0449c34f967dbf18a"
  vpn_instance_type = "t2.micro"
}
module "rds" {
  source                  = "../modules/rds"
  environment_code        = var.environment_code
  owner_technical         = var.owner_technical
  owner_business          = var.owner_business
  private_subnets         = module.vpc.private_subnets
  region_code             = var.region_code
  region                  = var.region
  rds_id                  = module.security-groups.rds_id
  rds_instance_class      = "db.t3.micro"
  backup_retention_period = "0"
  public_access           = "false"
  max_allocated_storage   = "30"
  engine                  = "mysql"
  engine_version          = "5.7"
  database_port           = "3306"
  storage_type            = "gp2"
  family                  = "mysql5.7"
  allocated_storage       = 30
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "01:00-03:00"
  deletion_protection     = false
}
module "roles" {
  source = "../modules/roles"

  environment_code = var.environment_code
  owner_technical  = var.owner_technical
  owner_business   = var.owner_business
  purpose_service  = var.purpose_service
  organization_prefix = var.organization_prefix
}
