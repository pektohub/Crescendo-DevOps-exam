resource "aws_security_group" "public" {
    name            = "Public Network SecGroup"
    description     = "security group for public network"
    vpc_id          = data.aws_vpc.default-vpc.id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
      Name          = "${var.project-name}-Public-SG"
      Environment   = var.tags_env
      Manage        = var.tags_manage
    }
}


# Security Group Rules
resource "aws_security_group_rule" "http" {
  security_group_id         = aws_security_group.public.id
  type                      = "ingress"
  from_port                 = 80
  to_port                   = 80
  protocol                  = "tcp"
  cidr_blocks               = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https" {
  security_group_id         = aws_security_group.public.id
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  cidr_blocks               = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  cidr_blocks               = [data.aws_vpc.default-vpc.cidr_block]
  security_group_id         = aws_security_group.public.id
}

# resource "aws_security_group_rule" "magnolia" {
#   type                      = "ingress"
#   from_port                 = 8080
#   to_port                   = 8080
#   protocol                  = "tcp"
#   cidr_blocks               = ["0.0.0.0/0"]
#   security_group_id         = aws_security_group.public.id
# }