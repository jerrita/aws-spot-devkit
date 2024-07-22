provider "aws" {
  region  = "ap-southeast-1" # Sinapore
  profile = "default"
}

locals {
  region              = "ap-southeast-1"
  instance_type       = "c6g.4xlarge"
  instance_types_list = [local.instance_type]
}

module "ec2_spot_price" {
  source                        = "fivexl/ec2-spot-price/aws"
  version                       = "2.0.0"
  instance_types_list           = local.instance_types_list
  availability_zones_names_list = data.aws_availability_zones.available.names
}

resource "tls_private_key" "state_ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key-${sha256(tls_private_key.state_ssh_key.public_key_openssh)}"
  public_key = tls_private_key.state_ssh_key.public_key_openssh
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "nixos_ami_aarch64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["NixOS-23.05*-aarch64-linux"]
  }
  owners = ["080433136561"] # NixOS
}

data "aws_ami" "nixos_ami_x86_64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["NixOS-23.05*-x86_64-linux"]
  }
  owners = ["080433136561"] # NixOS
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "machine" {
  ami                    = length(regexall(".*g\\..*", local.instance_types_list[0])) == 0 ? data.aws_ami.nixos_ami_x86_64.id : data.aws_ami.nixos_ami_aarch64.id
  key_name               = aws_key_pair.generated_key.key_name
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  ipv6_address_count     = 1

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  instance_market_options {
    spot_options {
      max_price                      = module.ec2_spot_price.spot_price_current_optimal
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
    market_type = "spot"
  }
}

output "private_key" {
  value     = tls_private_key.state_ssh_key.private_key_openssh
  sensitive = true
}

output "instance_ip" {
  value = aws_instance.machine.public_ip
}

output "instance_ipv6" {
  value = aws_instance.machine.ipv6_addresses[0]
}
