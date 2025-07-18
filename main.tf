terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "network" {
  source = "./modules/network"
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  name_prefix       = "prod"
}

module "compute" {
  source                = "./modules/compute"
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  ami_id                = var.ami
  instance_type         = var.instance_type
  user_data             = <<-EOF
                        #!/bin/bash
                        yum install -y httpd
                        systemctl start httpd
                        systemctl enable httpd
                        echo "Hello from Terraform managed EC2" > /var/www/html/index.html
                        EOF
  name_prefix           = "prod"
}