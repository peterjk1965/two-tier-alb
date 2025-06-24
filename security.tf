#public instances
resource "aws_security_group" "allow" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.pjk-vpc.id

  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my-ipv4]
  }

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my-ipv4]
  }

  ingress {
    description = "SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.lb_sg.id] # Reference to the source security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-tls"
  }
}


#bastion jump host
resource "aws_security_group" "only-ssh-bastion" {
  name        = "ssh-bastion"
  description = "Allow SSH for bastion"
  vpc_id      = aws_vpc.pjk-vpc.id

  ingress {
    description = "SSH into instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my-ipv4]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-bastion"
  }
}

#private instances
resource "aws_security_group" "private-allow" {
  name        = "ssh-private"
  description = "Allow SSH from bastion"
  vpc_id      = aws_vpc.pjk-vpc.id

  ingress {
    description     = "SSH into private instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.only-ssh-bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all-ipv4]
  }

  tags = {
    Name = "private-allow-tls"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id      = aws_vpc.pjk-vpc.id
  name        = "lb_security_group"
  description = "Allow inbound HTTP traffic to Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LoadBalancerSecurityGroup"
  }
}