provider "aws" {}

resource "aws_vpc" "nc-vpc-1" {
    cidr_block = var.cidr_block[0].cidr_block
    tags = {
        Name = var.cidr_block[0].name
    }
}

data "aws_vpc" "selected" {
    id = aws_vpc.nc-vpc-1.id
}

resource "aws_subnet" "nc-vpc-subnet-1" {
    vpc_id = data.aws_vpc.selected.id
    cidr_block = var.cidr_block[1].cidr_block
    tags = {
        Name: "${var.cidr_block[1].name}-${var.environment}"
    }
}
resource "aws_default_route_table" "nc-dev-rtb" {
  default_route_table_id = aws_vpc.nc-vpc-1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nc-dev-igw.id
  }

  tags = {
    Name = "${var.environment}-rtb"
  }
}


resource "aws_internet_gateway" "nc-dev-igw" {
  vpc_id = aws_vpc.nc-vpc-1.id

  tags = {
    Name = "${var.environment}-igw"
  }
}


resource "aws_default_security_group" "nc-dev-default-sg" {
    vpc_id = aws_vpc.nc-vpc-1.id

    ingress {
        description = "SSH Permission"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    egress {
        description = "Allow traffic to reach outside"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.environment}-default-sg"
    }

}


data "aws_ami" "latest-amazon-ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "root-device-type"
      values = ["ebs"]
    }
}

resource "aws_instance" "nc-aws-instance" {
  ami = data.aws_ami.latest-amazon-ami.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.nc-vpc-subnet-1.id
  security_groups = [aws_default_security_group.nc-dev-default-sg.id]

  associate_public_ip_address = true
  key_name = "orfiaj-key-pair"

  tags = {
    Name: "orfiaj-${var.environment}-server"
  }

}