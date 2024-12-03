##################################################
### APPLICATION LOAD BALANCER ###
##################################################

resource "aws_lb" "main" {
  name               = var.alb_name
  internal          = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.alb_sg.id]
  subnets            = slice(var.private_subnets, 0, 2)  # Only use the first 2 private subnets for the frontend
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.environment}-alb"
  }
}

##################################################
### SECURITY GROUP ###
##################################################

resource "aws_security_group" "alb_sg" {
  name  = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow inbound traffic on port 80 from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

##################################################
### LISTENER ###
##################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

##################################################
### TARGET GROUP ###
##################################################

resource "aws_lb_target_group" "main" {
  name         = "${var.environment}-alb-tg"
  port         = 3000
  protocol     = "HTTP"
  vpc_id       = var.vpc_id
  
  health_check {
    path     = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"  # Expect a 200 OK response
  }

  tags = {
    Name = "${var.environment}-alb-tg"
  }
}

##################################################
### TARGET GROUP ASSOCIATION ###
##################################################

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn    = aws_lb_target_group.main[0].arn
  target_id           = element(var.target_instance_ids, count.index)  # Attach the first 2 subnets
  port                = 3000
}