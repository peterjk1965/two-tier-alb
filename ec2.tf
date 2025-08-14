#A bastion host to provide easy access to the VPC. Not exactly "best practice", remove it it you wish.
#Note, as log as the bastion is only accessible from your IP address, this method is still considered secure.

resource "aws_instance" "bastion-host" {
  ami                    = var.ec2-ami
  instance_type          = var.default-instance
  availability_zone      = var.az-1
  subnet_id              = aws_subnet.public-subnet-a.id
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.only-ssh-bastion.id]

  tags = {
    Name = "bastion-host"
  }
}


#The origional Ec2 instances were replaced by a auto-scale group. I left these here just in case anyone still wanted a static instance
#that was not part of any auto scale group, for whatever reason, perhaps as a Jenkins host, etc.
# resource "aws_instance" "public-instance-a" {
#   ami                    = var.ec2-ami
#   instance_type          = var.default-instance
#   availability_zone      = var.az-1
#   subnet_id              = aws_subnet.public-subnet-a.id
#   key_name               = var.key-name
#   vpc_security_group_ids = [aws_security_group.allow.id]
#   user_data              = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install httpd -y
#               echo "Instance A. This is a restricted system." > /var/www/html/index.html
#               systemctl start httpd
#               systemctl enable httpd
#               EOF

#   tags = {
#     Name = "public-instance-a"
#   }
# }

# resource "aws_instance" "public-instance-b" {
#   ami                    = var.ec2-ami
#   instance_type          = var.default-instance
#   availability_zone      = var.az-2
#   subnet_id              = aws_subnet.public-subnet-b.id
#   key_name               = var.key-name
#   vpc_security_group_ids = [aws_security_group.allow.id]
#   user_data              = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install httpd -y
#               echo "Instance B. This is a restricted system." > /var/www/html/index.html
#               systemctl start httpd
#               systemctl enable httpd
#               EOF

#   tags = {
#     Name = "public-instance-b"
#   }
# }

# resource "aws_instance" "private-instance-a" {
#   ami                    = var.ec2-ami
#   instance_type          = var.default-instance
#   availability_zone      = var.az-1
#   subnet_id              = aws_subnet.private-subnet-a.id
#   key_name               = var.key-name
#   vpc_security_group_ids = [aws_security_group.private-allow.id]

#   tags = {
#     Name = "private-instance"
#   }
# }

# resource "aws_instance" "private-instance-b" {
#   ami                    = var.ec2-ami
#   instance_type          = var.default-instance
#   availability_zone      = var.az-2
#   subnet_id              = aws_subnet.private-subnet-b.id
#   key_name               = var.key-name
#   vpc_security_group_ids = [aws_security_group.private-allow.id]

#   tags = {
#     Name = "private-instance"
#   }
# }