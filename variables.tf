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
  default = "ami-05408afd665a9e1e0"
}

variable "all-ipv4" {
  type        = string
  default     = "0.0.0.0/0"
  description = "All IPv4 addresses - used for route tables and egress rules"
}

variable "default-instance" {
  type    = string
  default = "t3.micro"
}


variable "key-name" {
  type    = string
  default = "ohio"
}


variable "target_id_a" {
  description = "The ID of the target instance"
  type        = string
  default     = "public-instance-a"
}

variable "target_id_b" {
  description = "The ID of the target instance"
  type        = string
  default     = "public-instance-b"
}

