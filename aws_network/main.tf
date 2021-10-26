
#=======================================================================

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.env}-igw"
  }
}

#=======================================================================
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id 
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
      Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    "Name" = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
}

#======================================================================================

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  vpc = true
  tags = {
      "Name" = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  tags = {
    "Name" = "${var.env}-nat-gw-${count.index + 1}"
  }
}

#===================================================================================

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat[count.index].id 
  }
  tags = {
    "Name" = "${var.env}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
}

#=============================================================================


# data "aws_ami" "latest_amzlinux" {
#   owners = ["amazon"]
#    most_recent = true
#    filter {
#        name = "name"
#        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#    }
# }

# resource "aws_instance" "webserver1" {
#   ami = data.aws_ami.latest_amzlinux.id
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.webserver.id]
#   subnet_id = aws_subnet.private_subnets[0].id
#   key_name = "vatanabe"
#   #subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
#   user_data = <<EOF
# #!/bin/bash
# sudo yum -y update
# sudo yum -y install httpd
# myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
# echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!" > /var/www/html/index.html
# sudo service httpd restart
# EOF
#   tags = {
#     "Name" = "WebServer"
#   }
# }

# resource "aws_instance" "webserver2" {
#   ami = data.aws_ami.latest_amzlinux.id
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.webserver.id]
#   subnet_id = aws_subnet.public_subnets[1].id
#   key_name = "vatanabe"
#   #subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
#   user_data = <<EOF
# #!/bin/bash
# sudo yum -y update
# sudo yum -y install httpd
# myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
# echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!" > /var/www/html/index.html
# sudo service httpd restart
# EOF
#   tags = {
#     "Name" = "WebServer"
#   }
# }

# resource "aws_security_group" "webserver" {
#   name = "WebServer Security Group"
#   vpc_id = aws_vpc.main.id


#   ingress   {
#     cidr_blocks = [ "0.0.0.0/0" ]
#     from_port = 80
#     protocol = "tcp"
#     to_port = 80
#   }

#   ingress  {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port = 22
#     protocol = "tcp"
#     to_port = 22
#   }

#   egress  {
#     cidr_blocks = [ "0.0.0.0/0" ]
#     from_port = 0
#     protocol = "-1"
#     to_port = 0
#   }


#   tags = {
#     "Name" = "web-server-sg"
#     "Owner" = "Vatanabe"
#   }

# }