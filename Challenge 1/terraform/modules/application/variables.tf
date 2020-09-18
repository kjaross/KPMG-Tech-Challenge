variable "web_sg" {}

variable "elb_sg" {}

variable "vpc_id" {}

variable "filter_subnet" {
  type        = string
  default     = "KPMG-test-web-subnet-*"
}

variable "ami_id" {
  default = "ami-0528e14d9805ee940"
}

variable "key_name" {
  default = "test"
}
