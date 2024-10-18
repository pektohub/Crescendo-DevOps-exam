# Security Groups
locals {
  security_groups = {
    public  = aws_security_group.public.id
    private = aws_security_group.private.id
  }
}

resource "aws_security_group" "public" {
    name            = "Public Network SecGroup"
    description     = "security group for public network"
    vpc_id          = aws_vpc.main.id

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

resource "aws_security_group" "private" {
    name            = "Private Network SecGroup"
    description     = "security group for private network"
    vpc_id          = aws_vpc.main.id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
      Name          = "${var.project-name}-Private-SG"
      Environment   = var.tags_env
      Manage        = var.tags_manage
    }
}

# Security Group Rules
resource "aws_security_group_rule" "http" {
  for_each                  = local.security_groups
  security_group_id         = each.value
  type                      = "ingress"
  from_port                 = 80
  to_port                   = 80
  protocol                  = "tcp"
  cidr_blocks               = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_rule" "https" {
  for_each                  = local.security_groups
  security_group_id         = each.value  
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  cidr_blocks               = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_rule" "ssh" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  cidr_blocks               = [aws_vpc.main.cidr_block]
  security_group_id         = aws_security_group.private.id
}

resource "aws_security_group_rule" "tomcat" {
  type                    = "ingress"
  from_port               = 8080
  to_port                 = 8080
  protocol                = "tcp"
  cidr_blocks             = [aws_vpc.main.cidr_block]
  security_group_id       = aws_security_group.private.id
}