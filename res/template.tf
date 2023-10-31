resource "aws_vpc" "default_vpc" {
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = "10.0.0.0/16"
}

resource "aws_subnet" "default_subnet" {
  vpc_id                          = aws_vpc.default_vpc.id
  cidr_block                      = cidrsubnet(aws_vpc.default_vpc.cidr_block, 4, 1)
  map_public_ip_on_launch         = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.default_vpc.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true
}