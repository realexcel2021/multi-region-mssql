
################################################################################
# VPC for both regions
################################################################################


resource "aws_db_subnet_group" "this" {
  name       = "mssql-region-1"
  subnet_ids = var.subnet_ids_region1

  tags = {
    Name = "mssql-region-1"
  }
}

resource "aws_db_subnet_group" "this2" {
  name       = "mssql-region-2"
  subnet_ids = var.subnet_ids_region2

  provider = aws.region2

  tags = {
    Name = "mssql-region-2"
  }
}

module "security_group_region1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Replica MSSQL security group"
  vpc_id      = var.vpc_id_region_1

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = var.vpc_cidr_block
      
    },
  ]

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
  vpc_id      = var.vpc_id_region_2

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]

  tags = local.tags
}