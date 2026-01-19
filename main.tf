provider "aws" {
  region  = "me-central-1"
  profile = "default"
}
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = { Name = "${var.env_prefix}-vpc" }
}

resource "aws_subnet" "myapp_subnet" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags              = { Name = "${var.env_prefix}-subnet-1" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags   = { Name = "${var.env_prefix}-igw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.env_prefix}-rt" }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.myapp_subnet.id
  route_table_id = aws_route_table.rt.id
}
data "http" "my_ip" {
  url = "https://icanhazip.com"
}

locals {
  my_ip = "${chomp(data.http.my_ip.body)}/32"
}
resource "aws_security_group" "default_sg" {
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env_prefix}-default-sg" }
}
resource "aws_key_pair" "serverkey" {
  key_name   = "serverkey"
  public_key = file("/home/codespace/.ssh/id_ed25519.pub")
}
resource "aws_instance" "myapp_ec2" {
  ami                         = "ami-00c08fcaeeb2de00b" # Amazon Linux 2023 AMI
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp_subnet.id
  vpc_security_group_ids      = [aws_security_group.default_sg.id]
  availability_zone           = var.availability_zone
  key_name                    = aws_key_pair.serverkey.key_name
  associate_public_ip_address = true

  tags = { Name = "${var.env_prefix}-ec2-instance" }
}
