# Load Balancer with Correct Security Group and VPC
resource "aws_lb" "my_lb" {
  name               = "pjk-main-lb" # Updated name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]

  enable_deletion_protection = false

  tags = {
    Name = "pjk-main-lb"
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

# Output the Load Balancer DNS:
output "load_balancer_dns" {
  value = aws_lb.my_lb.dns_name
}

# Launch Template for EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = var.ec2-ami # Replace with your AMI
  instance_type = var.default-instance
  key_name      = "ohio" # Set here!

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.lb_sg.id]
  }

# Output displays the local ip address of the instance getting the traffic
  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install httpd -y

# Get IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token to get local IP
LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/local-ipv4)

echo "This is a restricted system. Private IP: $LOCAL_IP" > /var/www/html/index.html

systemctl start httpd
systemctl enable httpd
EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.web_target_group.arn]

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy (CPU-based)
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
