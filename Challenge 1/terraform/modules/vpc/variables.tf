variable "web_subnet_count" {
      default = 3
}

variable "app_subnet_count" {
      default = 3
}

variable "db_subnet_count" {
      default = 3
}

variable "vpc_name" {
      type    = string
      default = "KPMG-test"
}
