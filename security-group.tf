module "rds_proxy_1_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "rds-proxy-mssql-master"
  description = "Security group for mssql RDS proxy master access to lambda"
  vpc_id      = module.vpc_region1.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "sql server ports"
      cidr_blocks = "10.100.0.0/18"
    }
  ]
  egress_with_cidr_blocks = [ 
    {
      from_port = 1433
      to_port   = 1433
      protocol  = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
   ]
}
