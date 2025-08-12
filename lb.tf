# Load Balancer with Correct Security Group and VPC
resource "aws_lb" "my_lb" {
  name               = "web-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]

  enable_deletion_protection = false

  tags = {
    Name = "WebLoadBalancer"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.pjk-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 5
  }

  tags = {
    Name = "WebTargetGroup"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}


resource "aws_lb_target_group_attachment" "web_server_1_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.target_id_a
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.target_id_b
  port             = 80
}

# Output the Load Balancer DNS:
output "load_balancer_dns" {
  value = aws_lb.my_lb.dns_name
}


# Launch Template: Defines EC2 instance configuration
resource "aws_launch_template" "example" {
  name_prefix            = "example-"
  image_id               = var.ec2-ami          # Your AMI ID variable
  instance_type          = var.default-instance # Your instance type variable
  vpc_security_group_ids = [aws_security_group.allow.id]

  lifecycle {
    create_before_destroy = true # Safe update strategy
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "web-server"
      Environment = "dev"
    }
  }
}


# Auto Scaling Group: Uses the launch template to manage scaling
resource "aws_autoscaling_group" "example_asg" {
  name_prefix      = "web-asg-"
  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  vpc_zone_identifier = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "example-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }
}

# Launch Template for EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = var.ec2-ami   # Replace with your AMI
  instance_type = var.default-instance

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.lb_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                      = "web-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier = [aws_subnet.public-subnet-a.id,aws_subnet.public-subnet-b.id]
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.main.arn]

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy (CPU-based example)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# Lifecycle Hook (e.g., on instance launch)
resource "aws_autoscaling_lifecycle_hook" "instance_launch" {
  name                   = "instance-launch-hook"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
}

#add ASG

