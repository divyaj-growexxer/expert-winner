
variable "environment_code" {
}

variable "owner_technical" {
}

variable "owner_business" {
}

variable "region" {
}

variable "region_code" {
}

variable "vpc_id" {
}

variable "elb_id" {
}

variable "organization_prefix" {
}

variable "tld" {
}

variable "public_subnets" {
  type = list(string)
}

variable "purpose_service" {
  type = map(string)

  default = {
    elb           = "loadbalancer"
    rds           = "database"
    elasticsearch = "search"
    sonar         = "codequality"
    app           = "magento-app"
  }
}

