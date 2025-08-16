module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"
  internal = true # Set to false if you want an internet-facing ALB
  version = "9.16.0"

  name    = "${var.project}-${var.environment}-backend-alb" #roboshop-dev-backend-alb
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  create_security_group = false
  security_groups = [local.backend_alb_sg_id]
  enable_deletion_protection = false
  
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-backend-alb"
    }
  )  
}

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Backend ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name  = "*.backend-dev.${var.zone_name}" # something.backend-dev.newgenrobots.site
  type = "A"

  alias {
    name = module.backend_alb.dns_name
    zone_id = module.backend_alb.zone_id # This is the ZONE ID of ALB
    evaluate_target_health = true
  }   
}