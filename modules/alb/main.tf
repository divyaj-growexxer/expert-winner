
locals {
  common_tags = {
    "owner:technical"     = var.owner_technical
    "purpose:environment" = var.environment_code
    "owner:business"      = var.owner_business
  }
}

data "aws_acm_certificate" "cert_global" {
  domain   = "${var.environment_code}.${var.organization_prefix}.${var.tld}"
  statuses = ["ISSUED"]
}

########
# ALB #
########

resource "aws_alb" "alb" {
  name            = "elb-${var.environment_code}-magento"
  security_groups = [var.elb_id]
  subnets         = var.public_subnets

  tags = merge(
    local.common_tags,
    {
      "Name"            = "alb-${var.environment_code}-magento"
      "description"     = "Default application load balancer for magento-cluster in ${var.environment_code} environment"
      "purpose:role"    = "magento"
      "purpose:service" = var.purpose_service["elb"]
    },
  )
}

#############################
# magento Target group #
#############################
resource "aws_alb_target_group" "magento" {
  name                 = "magento-${var.environment_code}-tg"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  target_type = "ip"
 lifecycle {
        create_before_destroy = true
    }
  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    interval            = "6"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = merge(
    local.common_tags,
    {
      "Name"            = "tg-${var.environment_code}-magento"
      "description"     = "Default target group for magento in ${var.environment_code} loadbalancer"
      "purpose:role"    = "magento"
      "purpose:service" = var.purpose_service["elb"]
    },
  )
}



#############################
# https listener #
#############################

resource "aws_alb_listener" "alb-listener-https" {
  load_balancer_arn = aws_alb.alb.id

  port            = "443"
  protocol        = "HTTPS"
  certificate_arn = data.aws_acm_certificate.cert_global.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.magento.arn
  }
}


##################################
# http listener with redirection #
##################################
resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = "${aws_alb.alb.id}"

  port     = "80"
  protocol = "HTTP"


  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}






#############################
# Rules #
#############################
resource "aws_alb_listener_rule" "magento" {
  depends_on   = [aws_alb_target_group.magento]
  listener_arn = aws_alb_listener.alb-listener-https.arn
  priority     = "1"

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.magento.id
  }

  condition {
    host_header {
      values = ["${var.environment_code}.${var.organization_prefix}.${var.tld}"]
    }
  }
}
