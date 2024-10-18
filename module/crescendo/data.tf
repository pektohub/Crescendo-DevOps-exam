data "aws_availability_zones" "az" {}

data "aws_ami" "ubuntu_24_04_lts" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]  
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]  
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]  
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]  
  }

  owners = ["099720109477"] 
}