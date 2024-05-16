module "rds_proxy" {
  source = "terraform-aws-modules/rds-proxy/aws"

  name                   = "rds-proxy-master"
  iam_role_name          = "rds-proxy-master-role"
  vpc_subnet_ids         = var.subnet_ids_region1
  vpc_security_group_ids = ["${module.rds_proxy_1_sg.security_group_id}"]

  endpoints = {
    read_write = {
      name                   = "read-write-endpoint"
      vpc_subnet_ids         = var.subnet_ids_region1
      vpc_security_group_ids = ["${module.rds_proxy_1_sg.security_group_id}"]
    }
    # read_only = {
    #   name                   = "read-only-endpoint"
    #   vpc_subnet_ids         = ["subnet-30ef7b3c", "subnet-1ecda77b", "subnet-ca09ddbc"]
    #   vpc_security_group_ids = ["sg-f1d03a88"]
    #   target_role            = "READ_ONLY"
    # }
  }

  auth = {
    "replica_mssql" = {
      description        = "MSSQL superuser password"
      secret_arn         = "${aws_secretsmanager_secret.db_pass.arn}"
    }
  }

  # Target Aurora cluster
  engine_family         = "SQLSERVER"
  target_db_instance     = true
  db_instance_identifier = module.master.db_instance_identifier

  tags = {
    project = "multi-region-deploy"
  }
}



