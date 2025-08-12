data "http" "my_current_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_current_ip.response_body)}/32"
}
