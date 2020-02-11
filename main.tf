provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "tls_private_key" "privkey" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "public_key" {
  key_name   = var.key_name
  public_key = tls_private_key.privkey.public_key_openssh
}

resource "aws_security_group" "instance_sg" {
  name        = "${var.app}-sg"
  description = "Security group configuration for ${var.app}"

  dynamic "ingress" {
    for_each = var.instance_ingress
    content {
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  dynamic "egress" {
    for_each = var.instance_egress
    content {
      from_port   = lookup(egress.value, "from_port", null)
      to_port     = lookup(egress.value, "to_port", null)
      protocol    = lookup(egress.value, "protocol", null)
      cidr_blocks = lookup(egress.value, "cidr_blocks", null)
    }
  }

  tags = {
    Name = "${var.app}-sg"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix            = "${var.app}-lc"
  image_id               = var.image_id
  instance_type          = var.instance_type
  security_groups        = ["${aws_security_group.instance_sg.id}"]
  key_name               = var.key_name
  user_data              = var.user_data
  enable_monitoring      = var.enable_monitoring
              
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autosg_gr" {
  name = "${var.app}-auto-sg"

  launch_configuration      = aws_launch_configuration.launch_configuration.id
  vpc_zone_identifier       = data.aws_subnet_ids.subnet_ids.ids
  default_cooldown          = var.default_cooldown
  health_check_grace_period = var.health_check_grace_period
  force_delete              = var.force_delete
  
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity

  tags = [
    {
      key = "Name"
      value = "${var.app}-sg"
      propagate_at_launch = true
    }
  ]

  depends_on = [aws_launch_configuration.launch_configuration]
}

resource "aws_autoscaling_policy" "cpu_high" {
  name                   = "${var.app}-cpu-high"
  autoscaling_group_name = aws_autoscaling_group.autosg_gr.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "1"
  cooldown               = "300"
}

resource "aws_autoscaling_policy" "cpu_low" {
  name                   = "${var.app}-cpu-low"
  autoscaling_group_name = aws_autoscaling_group.autosg_gr.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "-1"
  cooldown               = "300"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "${var.app}-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.cpu_high.arn}"]
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.autosg_gr.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  alarm_name          = "${var.app}-cpu-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.cpu_low.arn}"]
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.autosg_gr.name}"
  }
}

resource "aws_security_group" "app_lb_sg" {
  name        = "${var.app}-lb-sg"
  description = "Security group configuration for ${var.app} load balancer"

  dynamic "ingress" {
    for_each = var.lb_ingress
    content {
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  dynamic "egress" {
    for_each = var.lb_egress
    content {
      from_port   = lookup(egress.value, "from_port", null)
      to_port     = lookup(egress.value, "to_port", null)
      protocol    = lookup(egress.value, "protocol", null)
      cidr_blocks = lookup(egress.value, "cidr_blocks", null)
    }
  }

  tags = {
    Name = "${var.app}-lb-sg"
  }
}

resource "aws_lb" "alb" {  
  name            = "${var.app}-alb" 
  load_balancer_type = "application"
  subnets         = var.subnets
  security_groups = ["${aws_security_group.app_lb_sg.id}"]
  internal        = false 
  idle_timeout    = 60
}

resource "aws_lb_target_group" "target_group" {
	name	= "${var.app}-target-group"
	vpc_id	= data.aws_vpc.default.id
	port	= "80"
	protocol	= "HTTP"

  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = true 
  }   

	health_check {
    path = "/"
    port = "80"
    protocol = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    timeout = 4
    matcher = "200-308"
  }
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn = aws_lb.alb.arn 
  port              = "80"
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"  
  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = aws_lb_target_group.target_group.arn
  autoscaling_group_name = aws_autoscaling_group.autosg_gr.id
}