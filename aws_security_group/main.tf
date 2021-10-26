resource "aws_security_group" "webserver" {
  name = "WebServer Security Group"
  vpc_id = aws_vpc.prod-vpc.id


  ingress   {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }


  tags = {
    "Name" = "web-server-sg"
    "Owner" = "Vatanabe"
  }

}