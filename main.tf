provider "aws" {
  region = local.region1
}

provider "aws" {
  alias  = "region2"
  region = local.region2
}

data "aws_caller_identity" "current" {}

locals {
  name    = "replica-mssql"
  region1 = "us-east-1"
  region2 = "us-east-2"

  tags = {
    Name       = local.name
  }

  engine                = "sqlserver-ee"
  engine_version        = "15.00"
  family                = "sqlserver-ee-15.0" # DB parameter group
  major_engine_version  = "15.00"         # DB option group
  instance_class        = "db.t3.xlarge"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 1433
}

################################################################################
# Master DB
################################################################################

module "master" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-master"

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class
  storage_encrypted    = false 
  license_model = "license-included"

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  #db_name  = "replicamssql"
  username = "replica_mssql"
  password = random_password.password.result
  port     = local.port

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.security_group_region1.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  manage_master_user_password = false

  tags = local.tags
}

################################################################################
# Replica DB
################################################################################

module "kms" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.0"
  description = "KMS key for cross region replica DB"

  # Aliases
  aliases                 = [local.name]
  aliases_use_name_prefix = true

  key_owners = [data.aws_caller_identity.current.id]

  tags = local.tags

  providers = {
    aws = aws.region2
  }
}

module "replica" {
  source = "terraform-aws-modules/rds/aws"

  providers = {
    aws = aws.region2
  }

  identifier = "${local.name}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = module.master.db_instance_arn
  

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class
  #kms_key_id           = module.kms.key_arn
  create_db_parameter_group = false
  create_db_option_group = false

  #allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = false 

  #password = "UberSecretPassword"
  # Not supported with replicas
  manage_master_user_password = false
  license_model = "license-included"

  # Username and password should not be set for replicas
  port = local.port

  multi_az               = false
  vpc_security_group_ids = [module.security_group_region2.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  # Specify a subnet group created in the replica region
  db_subnet_group_name = aws_db_subnet_group.this2.name

  tags = local.tags
}
