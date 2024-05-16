variable "subnet_ids_region1" {
  type = list(string) 
  description = "data base subnets for region 1"
}

variable "subnet_ids_region2" {
  type = list(string)
  description = "database subnets for region 2"
}

variable "vpc_id_region_1" {
  type = string
}

variable "vpc_id_region_2" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}


