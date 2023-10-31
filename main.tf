provider "aws" {
  region  = "ap-southeast-1" # Sinapore
  profile = "default"
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

locals {
  # Osaka: c6i, x5d
  # Sinapore: c7g

  instance_types_list = ["c7g.xlarge"]
  nixos_images = {
    # 23.05-Sinapore
    amd64   = "ami-0df021bbad056ac1e"
    aarch64 = "ami-04a77f24cfc55081f"
  }
}

module "ec2_spot_price" {
  source                        = "fivexl/ec2-spot-price/aws"
  version                       = "2.0.0"
  instance_types_list           = local.instance_types_list
  availability_zones_names_list = data.aws_availability_zones.available.names
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "machine" {
  ami                    = local.nixos_images.aarch64 # Maybe you want change this
  key_name               = aws_key_pair.generated_key.key_name
  instance_type          = local.instance_types_list[0]
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  instance_market_options {
    spot_options {
      max_price                      = module.ec2_spot_price.spot_price_current_max
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
    market_type = "spot"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

output "private_key" {
  value     = tls_private_key.state_ssh_key.private_key_openssh
  sensitive = true
}

output "instance_ip" {
  value = aws_instance.machine.public_ip
}
