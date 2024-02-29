resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/26"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-hands0n-1"
  }

}

output "vpc_id" {
  value = aws_vpc.vpc.id

}

data "aws_availability_zones" "azs" {
  state = "available"

}

resource "aws_subnet" "publicSubnet-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1a-public"
  }

}

output "publicSubnet-1a_id" {
  value = aws_subnet.publicSubnet-1a.id

}

resource "aws_subnet" "publicSubnet-1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.16/28"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1b-public"
  }

}

output "publicSubnet-1b_id" {
  value = aws_subnet.publicSubnet-1b.id

}

resource "aws_subnet" "privateSubnet-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.32/28"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_1a"
  }

}

output "privateSubnet-1a_id" {
  value = aws_subnet.privateSubnet-1a.id
}

resource "aws_subnet" "privateSubnet-1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.48/28"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_1b"
  }

}

output "privateSubnet-1b_id" {
  value = aws_subnet.privateSubnet-1b.id

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw_handson-1"
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "eip_handson-2"
  }
}

output "eip" {
  value = aws_eip.eip.id

}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.privateSubnet-1a.id

  tags = {
    Name = "natGw_handsOn"
  }

}

output "nat_gateway" {
  value = aws_nat_gateway.nat_gateway.id

}

resource "aws_route_table" "public_rt_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt_table"
  }

}

output "public_rt_table" {
  value = aws_route_table.public_rt_table.id

}

resource "aws_route_table_association" "public_rt_1a" {
  route_table_id = aws_route_table.public_rt_table.id
  subnet_id      = aws_subnet.publicSubnet-1a.id

}
resource "aws_route_table_association" "public_rt_1b" {
  route_table_id = aws_route_table.public_rt_table.id
  subnet_id      = aws_subnet.publicSubnet-1b.id

}

resource "aws_route_table" "private_rt_table" {
  vpc_id = aws_vpc.vpc.id



  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_rt_table"
  }
}

output "private_rt_table" {
  value = aws_route_table.private_rt_table.id

}

resource "aws_route_table_association" "private_rt_1a" {
  subnet_id      = aws_subnet.privateSubnet-1a.id
  route_table_id = aws_route_table.private_rt_table.id

}

resource "aws_route_table_association" "private_rt_1b" {
  subnet_id      = aws_subnet.privateSubnet-1b.id
  route_table_id = aws_route_table.private_rt_table.id

}

resource "aws_security_group" "sgrp_ec2" {
  name        = "sgrp_ec2"
  description = "allow SSH AND HTTP"
  vpc_id      = aws_vpc.vpc.id
  tags        = { Name = "public_security_group" }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH to EC2 instance"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "going traffic to web server"
  }

}

output "public_sgrp" {
  value = aws_security_group.sgrp_ec2.id

}

data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*x86_64-gp2"]
  }

}

data "aws_key_pair" "SSH_key" {
  key_name = "tentek"

}

resource "aws_instance" "public_1a_ec2" {
  ami                    = data.aws_ami.amazon_linux_ami.id
  subnet_id              = aws_subnet.publicSubnet-1a.id
  vpc_security_group_ids = [aws_security_group.sgrp_ec2.id]
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.SSH_key.key_name
  user_data              = <<EOF
  #!bin/bash
  yum update -y
  yum install httpd  -y
  systemctl start httpd
  systemctl enable httpd 
  echo "<h1>This is my $(hostname -f) instnace </h1>" > /var/www/html/index.html
  EOF

  tags = { Name = "public_1a_ec2" }
}

output "public_1a_ec2" {
  value = aws_instance.public_1a_ec2.id

}

resource "aws_instance" "public_1b_ec2" {
  ami                    = data.aws_ami.amazon_linux_ami.id
  subnet_id              = aws_subnet.publicSubnet-1b.id
  vpc_security_group_ids = [aws_security_group.sgrp_ec2.id]
  key_name               = data.aws_key_pair.SSH_key.key_name
  instance_type          = "t2.micro"
  user_data              = file("user_data.sh")

  tags = { Name = "public_1b_ec2" }

}

output "public_1b_ec2" {
  value = aws_instance.public_1b_ec2.id

}





