# Networking
module "networking" {
  source      = "./modules/networking"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

# Security Group
module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.networking.vpc_id
}

# EC2
module "minecraft_ec2" {
  source            = "./modules/ec2"
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security_group.security_group_id
  instance_name     = "minecraft-ec2-awan-dev"
}
