
variable "environment_code" {
  type = string
}

variable "owner_technical" {
  type = string
}

variable "organization_prefix" {
  type = string
}

variable "owner_business" {
  type = string
}

variable "tld" {
}

variable "region" {
  type = string
}

variable "region_code" {
  description = "The region code where resource is locate i.e ew1 or aps1"
  type        = string
}

variable "vpc_cidr_block" {
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "protected_subnets" {
  description = "A list of protected subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "elasticis_ips" {
  type        = list(string)
  description = "Innovify public ip to allow access to resources"
}

#variable "domain_names" {
#  type = list(string)
#}

variable "node_instance_type" {
}

variable "node_ami_id" {
}

variable "key_name" {
}

variable "api_min_size" {
}

variable "api_max_size" {
}

