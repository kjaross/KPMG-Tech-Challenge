resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
      Name = var.vpc_name
    }
}

resource "aws_internet_gateway" "igw" {
     vpc_id = aws_vpc.vpc.id
     tags = {
       Name = "${var.vpc_name}-igw"
     }
}

resource "aws_route_table" "internet_route" {
    vpc_id = aws_vpc.vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "${var.vpc_name}-route"
    }
}

#Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration.
data "aws_availability_zones" "available" {}

resource "aws_subnet" "web_subnet" {
    count                   = var.web_subnet_count
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.${10+count.index}.0/24"

    #Specify true to indicate that instances launched into the subnet should be assigned a public IP address
    map_public_ip_on_launch = true 

    availability_zone       = element(data.aws_availability_zones.available.names, count.index)  #element(list, index)
    tags = {
      Name  = "${var.vpc_name}-web-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "app_subnet" {
    count                   = var.app_subnet_count
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.${20+count.index}.0/24"
    map_public_ip_on_launch = false
    availability_zone       = element(data.aws_availability_zones.available.names, count.index)
    tags = {
      Name  = "${var.vpc_name}-app-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "db_subnet" {
    count                   = var.db_subnet_count
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.${30+count.index}.0/24"
    map_public_ip_on_launch = false
    availability_zone       = element(data.aws_availability_zones.available.names, count.index)
    tags = {
      Name  = "${var.vpc_name}-db-subnet-${count.index + 1}"
    }
}

#association between a route table and a subnet OR a route table and an internet gateway or virtual private gateway
resource "aws_route_table_association" "public" {
   count          = var.web_subnet_count
   subnet_id      = element(aws_subnet.web_subnet.*.id, count.index)
   route_table_id = aws_route_table.internet_route.id
}
