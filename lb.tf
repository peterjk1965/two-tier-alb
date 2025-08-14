resource "aws_lb" "my_lb" {
  name               = "pjk-main-lb"   # Updated name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]

  enable_deletion_protection = false

  tags = {
    Name = "pjk-main-lb"
  }
}
