
################################################################################
# VPC for both regions
################################################################################

module "vpc_region1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = "10.100.0.0/18"

  azs              = ["${local.region1}a", "${local.region1}b", "${local.region1}c"]
  public_subnets   = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
  private_subnets  = ["10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/24"]
  database_subnets = ["10.100.7.0/24", "10.100.8.0/24", "10.100.9.0/24"]

  create_database_subnet_group = true

  tags = local.tags
}

module "security_group_region1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Replica MSSQL security group"
  vpc_id      = module.vpc_region1.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = module.vpc_region1.vpc_cidr_block
      
    },
  ]

  tags = local.tags
}

module "vpc_region2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.region2
  }

  name = local.name
  cidr = "10.100.0.0/18"

  azs              = ["${local.region2}a", "${local.region2}b", "${local.region2}c"]
  public_subnets   = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
  private_subnets  = ["10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/24"]
  database_subnets = ["10.100.7.0/24", "10.100.8.0/24", "10.100.9.0/24"]

  create_database_subnet_group = true

  tags = local.tags
}

module "security_group_region2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.region2
  }

  name        = local.name
  description = "Replica MSSQL security group"
  vpc_id      = module.vpc_region2.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = module.vpc_region2.vpc_cidr_block
    },
  ]

  tags = local.tags
}