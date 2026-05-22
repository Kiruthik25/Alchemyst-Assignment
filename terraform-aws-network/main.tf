module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
}

module "public_ec2" {
  source = "./modules/ec2"

  instance_name = "public-server"

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.network.public_subnet_id
  security_group   = module.security.public_sg_id
  key_name         = var.key_name
  associate_public = true

  user_data = file("userdata.sh")
}

module "private_ec2_1" {
  source = "./modules/ec2"

  instance_name = "private-server-1"

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.network.private_subnet_id
  security_group   = module.security.private_sg_id
  key_name         = var.key_name
  associate_public = false

  user_data = file("userdata.sh")
}

module "private_ec2_2" {
  source = "./modules/ec2"

  instance_name = "private-server-2"

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.network.private_subnet_id
  security_group   = module.security.private_sg_id
  key_name         = var.key_name
  associate_public = false

  user_data = file("userdata.sh")
}
