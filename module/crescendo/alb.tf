resource "aws_lb" "alb" {
  name                              = "${var.project-name}-alb"
  internal                          = false
  load_balancer_type                = "application"
  security_groups                   = [ aws_security_group.public.id ]
  subnets                           = tolist(aws_subnet.public_subnet[*].id) 
  ip_address_type                   = "ipv4"
  enable_http2                      = true
  enable_deletion_protection        = false
  drop_invalid_header_fields        = false
  enable_cross_zone_load_balancing  = true
  idle_timeout                      = 60

  tags = {
    Name        = "${var.project-name}-alb"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
  
  tags_all = {
    Name        = "${var.project-name}-alb"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }

}


resource "aws_lb_target_group" "nginx-tg" {
  name                               = "${var.project-name}-nginx-tg"
  port                               = 80
  protocol                           = "HTTP"
  vpc_id                             = aws_vpc.main.id
  target_type                        = "instance"
  deregistration_delay               = 300
  load_balancing_algorithm_type      = "round_robin"
  lambda_multi_value_headers_enabled = false
  proxy_protocol_v2                  = false

  depends_on = [
    aws_lb.alb
  ]
  health_check {
    enabled             = true
    interval            = 5
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    protocol            = "HTTP"
    matcher             = "200"
  }
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 10800
  }

  tags = {
    Name        = "${var.project-name}-Nginx-TG"
    Manage      = var.tags_manage
    Environment = var.tags_env
  }
}
resource "aws_lb_target_group" "tomcat-tg" {
  name                               = "${var.project-name}-nginx-tg"
  port                               = 8080
  protocol                           = "HTTP"
  vpc_id                             = aws_vpc.main.id
  target_type                        = "instance"
  deregistration_delay               = 300
  load_balancing_algorithm_type      = "round_robin"
  lambda_multi_value_headers_enabled = false
  proxy_protocol_v2                  = false

  depends_on = [
    aws_lb.alb
  ]
  health_check {
    enabled             = true
    interval            = 5
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    protocol            = "HTTP"
    matcher             = "200"
  }
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 10800
  }

  tags = {
    Name        = "${var.project-name}-Tomcat-TG"
    Manage      = var.tags_manage
    Environment = var.tags_env
  }
}


resource "aws_lb_target_group_attachment" "nginx" {
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "tomcat" {
  target_group_arn = aws_lb_target_group.tomcat-tg.arn
  target_id        = aws_instance.ec2.id
  port             = 8080
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      host = "#{host}"
      path = "/#{path}"
      port = "443"
      protocol = "HTTPS"
      query = "#{query}"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name        = "${var.project-name}-http-listener"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.acm.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "\"Unregistered domain from the Load Balancer\" or \"Invalid domain entry\" ."
      status_code  = "503"
    }
  }
    tags = {
        Name        = "${var.project-name}-https-listener"
        Environment = var.tags_env
        Manage      = var.tags_manage
  }
}

resource "aws_lb_listener_rule" "nginx-rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1
  action {
    order = 1
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }

  condition {
    host_header {
      values = ["nginx.aurbano.com"]
    }
  }
  tags = {
    Name        = "${var.project-name}-nginx-rule"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}
resource "aws_lb_listener_rule" "tomcat-rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 2
  action {
    order = 1
    type             = "forward"
    target_group_arn = aws_lb_target_group.tomcat-tg.arn
  }

  condition {
    host_header {
      values = ["tomcat.aurbano.com"]
    }
  }
  tags = {
    Name        = "${var.project-name}-tomcat-rule"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}