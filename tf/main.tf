provider "aws" {
  region 	 	  = var.region
  shared_credentials_files= [var.path_file_credentials]
  profile                 = var.profile_name
}

resource "aws_vpc" "tf_vpc" {
  cidr_block 		  = var.vpc_cidr
  tags = {
    Name = "tf_vpc"
    Username  = "victor.shvartsman"
  }
}

resource "aws_subnet" "tf_subnet" {
  availability_zone       = data.aws_availability_zones.zones.names[0]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  vpc_id                  = aws_vpc.tf_vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name = "tf_subnet"
    Username = "victor.shvartsman"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
    Username = "victor.shvartsman"
  }
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_route_table"
    Username = "victor.shvartsman"
  }
}

resource "aws_route" "tf_route" {
  route_table_id         = aws_route_table.tf_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_igw.id
}

resource "aws_route_table_association" "tf_rta" {
  subnet_id      = aws_subnet.tf_subnet.id
  route_table_id = aws_route_table.tf_rt.id
}

resource "aws_eip" "tf_eip" {
  network_interface = aws_network_interface.tf_nif.id

  depends_on = [
    aws_internet_gateway.tf_igw,
    aws_instance.tf_server
  ]

  tags = {
    Name = "server"
    Username = "victor.shvartsman"
  }
}

resource "aws_security_group" "tf_sg" {
  vpc_id      = aws_vpc.tf_vpc.id
  description = "Access to the application server"
  tags = {
    Name = "tf_sg"
    Username = "victor.shvartsman"
  }
  name = "Allow Taffic"

  ingress {
    description = "HTTP access from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access from Internet (for debug)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "tf_nif" {
  subnet_id       = aws_subnet.tf_subnet.id
  security_groups = [aws_security_group.tf_sg.id]
}

resource "aws_instance" "tf_server" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name      = "AWS-Victor"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.tf_nif.id
  }
  user_data = "${file("install_app.sh")}"
  tags = {
    Name = "server"
    Username = "victor.shvartsman"
  }
}
