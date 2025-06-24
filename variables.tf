variable "az-1" {
  type    = string
  default = "us-east-2a"
}

variable "az-2" {
  type    = string
  default = "us-east-2b"
}

variable "ec2-ami" {
  type    = string
  default = "ami-04985531f48a27ae7"
}

variable "all-ipv4" {
  type    = string
  default = "0.0.0.0/0"
}

variable "default-instance" {
  type    = string
  default = "t2.micro"
}

variable "my-ipv4" {
  type    = string
  default = "24.1.237.243/32"
}

variable "key-name" {
  type    = string
  default = "ohio"
}

#fix me
variable "bastion" {
  type    = string
  default = "10.0.1.193/32"
}



