variable "name" {
  default = "WebServer Security Group"
}

variable "vpc_id" {
  default = "vpc-0a0d164a05c3703e7"
}

variable "ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}
