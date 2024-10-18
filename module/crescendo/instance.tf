resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu_24_04_lts.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [ aws_security_group.public.id ]
  ebs_optimized               = true
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = data.aws_subnet.default-subnets.id
  associate_public_ip_address = true

   root_block_device {
       delete_on_termination = true
       volume_type           = "gp3"
       volume_size           = 20
   
       tags ={
           Name        = "${var.project-name}-EBS"
           Environment = var.tags_env
           Manage      = var.tags_manage
       }
     }

  tags = {
    Name            = "${var.project-name}-EC2"
    Environment     = var.tags_env
    Manage          = var.tags_manage

  }

  user_data = "${file("magnolia-cms.sh")}"
}

resource "aws_key_pair" "keypair" {
  key_name   = var.project-name
  public_key = var.pubkey

  tags = {
    Name        = "${var.project-name}-keypair"
    Manage      = var.tags_manage
    Environment = var.tags_env
      }
}