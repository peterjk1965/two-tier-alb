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

#moved to main.tf
# variable "all-ipv4" {
#   type    = string
#   default = "0.0.0.0/0"
# }

variable "all-ipv4" {
  type        = string
  default     = "0.0.0.0/0"
  description = "All IPv4 addresses - used for route tables and egress rules"
}

variable "default-instance" {
  type    = string
  default = "t2.micro"
}

# variable "my-ipv4" {
#   type    = string
#   default = "24.1.237.243/32"
# }

variable "key-name" {
  type    = string
  default = "ohio"
}

#fix me
# variable "bastion" {
#   type    = string
#   default = "10.0.1.193/32"
# }

# variable "target_id_a" {
#   description = "The ID of the target instance"
#   type        = string
#   default     = "public-instance-a"
# }

# variable "target_id_b" {
#   description = "The ID of the target instance"
#   type        = string
#   default     = "public-instance-b"
# }

