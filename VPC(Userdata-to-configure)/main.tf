## VPC ap-south-1 configuration 
resource "aws_vpc" "vpc01" {
  provider = aws.ap-south-1
  cidr_block = var.cidr_vpc01
  tags = {
    Name = "VPC01"
  }
}

# Create Public Subnet
resource "aws_subnet" "pubsub_vpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc01.id
  cidr_block = var.cidr_pubsub_vpc01
  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "prvsub_vpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc01.id
  cidr_block = var.cidr_prvsub_vpc01
  tags = {
    Name = "Private Subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igwvpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "igwvpc01"
  }
}

# Create Public Route Table and attach internet gateway to route table
resource "aws_route_table" "pubroutevpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwvpc01.id
  }

  tags = {
    Name = "pubroutevpc01"
  }
}


# Associate Public Subnet to Public Route Table
resource "aws_route_table_association" "routeassoc1" {
    provider = aws.ap-south-1
    subnet_id = aws_subnet.pubsub_vpc01.id
    route_table_id = aws_route_table.pubroutevpc01.id
}

# Create Elastic IP
resource "aws_eip" "nateipvpc01" {
  provider = aws.ap-south-1
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "natvpc01" {
  provider = aws.ap-south-1
  allocation_id = aws_eip.nateipvpc01.id
  subnet_id = aws_subnet.pubsub_vpc01.id
  tags = {
    Name = "Nat VPC01"
  }
}

# Create Private Route table and attach NAT Gateway to route
resource "aws_route_table" "prvroutevpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natvpc01.id
  }
  tags = {
    Name = "prvroutevpc01"
  }
}

# Associate private subnet to private route table
resource "aws_route_table_association" "routeassoc2" {
  provider = aws.ap-south-1
  subnet_id = aws_subnet.prvsub_vpc01.id
  route_table_id = aws_route_table.prvroutevpc01.id
}



## VPC us-east-1  configuration
resource "aws_vpc" "vpc02" {
  provider = aws.us-east-1
  cidr_block = var.cidr_vpc02
  tags = {
    Name = "vpc02"
  }
}

# Create Public Subnet
resource "aws_subnet" "pubsub_vpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc02.id
  cidr_block = var.cidr_pubsub_vpc02
  tags = {
    Name = "Public Subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "prvsub_vpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc02.id
  cidr_block = var.cidr_prvsub_vpc02
  tags = {
    Name = "Private Subnet"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "igwvpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc02.id
  tags = {
    Name = "igwvpc02"
  }
}

# Create Public Route table and attach internet gateway to the route table
resource "aws_route_table" "pubroutevpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc02.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwvpc02.id
  }

  tags = {
    Name = "pubroutevpc02"
  }
}

# Associate public subnets to public route table
resource "aws_route_table_association" "routeassoc3" {
    provider = aws.us-east-1
    subnet_id = aws_subnet.pubsub_vpc02.id
    route_table_id = aws_route_table.pubroutevpc02.id
  
}

# Create elastic IP
resource "aws_eip" "nateipvpc02" {
  provider = aws.us-east-1
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "natvpc02" {
  provider = aws.us-east-1
  allocation_id = aws_eip.nateipvpc02.id
  subnet_id = aws_subnet.pubsub_vpc02.id
  tags = {
    Name = "Nat vpc02"
  }
}

# Create Private Route Table and attach NAT gateway to route
resource "aws_route_table" "prvroutevpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc02.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natvpc02.id
  }
  tags = {
    Name = "prvroutevpc02"
  }
}

# Associate private subnet to private route table
resource "aws_route_table_association" "routeassoc4" {
  provider = aws.us-east-1
  subnet_id = aws_subnet.prvsub_vpc02.id
  route_table_id = aws_route_table.prvroutevpc02.id
}


## VPC Peering between ap-south-1 and us-east-1
resource "aws_vpc_peering_connection" "peer" {
    provider = aws.ap-south-1
    vpc_id = aws_vpc.vpc01.id
    peer_vpc_id = aws_vpc.vpc02.id
    peer_region = "us-east-1"
    auto_accept = false

    tags = {
      Name = "vpc01-vpc02"
      Side = "Requester"
    }
}

resource "aws_vpc_peering_connection_accepter" "peer_accept" {
    provider = aws.us-east-1
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    auto_accept = true
    tags = {
      Name = "vpc01-vpc02"
      Side = "Accepter"
    }
}

## Add the vpc peering to the route tables
resource "aws_route" "r1" {
  provider = aws.ap-south-1
  route_table_id = aws_route_table.pubroutevpc01.id
  destination_cidr_block = aws_vpc.vpc02.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "r2" {
  provider = aws.ap-south-1
  route_table_id = aws_route_table.prvroutevpc01.id
  destination_cidr_block = aws_vpc.vpc02.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "r3" {
  provider = aws.us-east-1
  route_table_id = aws_route_table.pubroutevpc02.id
  destination_cidr_block = aws_vpc.vpc01.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "r4" {
  provider = aws.us-east-1
  route_table_id = aws_route_table.prvroutevpc02.id
  destination_cidr_block = aws_vpc.vpc01.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

#Generate keypair for instances in ap-south-1 and us-east-1
resource "aws_key_pair" "keypairmum" {
  provider = aws.ap-south-1
  key_name = "terraform-key"
  public_key = file("C:/Users/Vijesh/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "keypairus" {
  provider = aws.us-east-1
  key_name = "terraform-key"
  public_key = file("C:/Users/Vijesh/.ssh/id_rsa.pub")
}

# Security group vpc1 (ap-south-1)
resource "aws_security_group" "sgvpc01" {
  provider = aws.ap-south-1
  name = "web"
  vpc_id = aws_vpc.vpc01.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
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

  tags = {
    Name = "sgvpc01"
  }
}

# Security groups vpc2 (us-east-1)
resource "aws_security_group" "sgvpc02" {
  provider = aws.us-east-1
  name = "sgvpc02"
  vpc_id = aws_vpc.vpc02.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
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

  tags = {
    Name = "sgvpc02"
  }
}

## Creating instances 1 public bastion and  2 private instances in each private subnets 
resource "aws_instance" "instance1vpc02" {
  provider = aws.us-east-1
  ami = var.us-east-ami
  instance_type = var.us-east-instance
  subnet_id = aws_subnet.pubsub_vpc02.id
  key_name = aws_key_pair.keypairus.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc02.id]
  associate_public_ip_address = true
  user_data = base64encode(file("configure.sh"))
  tags = {
    Name = "instance1vpc02"
  }
}

resource "aws_instance" "instance2vpc02" {
  provider = aws.us-east-1
  ami = var.us-east-ami
  instance_type = var.us-east-instance
  subnet_id = aws_subnet.prvsub_vpc02.id
  key_name = aws_key_pair.keypairus.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc02.id]
  user_data = base64encode(file("configure.sh"))

  tags = {
    Name = "instance2vpc02"
  }
}

resource "aws_instance" "instance1vpc01" {
  provider = aws.ap-south-1
  ami = var.ap-south-ami
  instance_type = var.ap-south-instance
  subnet_id = aws_subnet.prvsub_vpc01.id
  key_name = aws_key_pair.keypairmum.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc01.id]
  user_data = base64encode(file("configure.sh"))
  tags = {
    Name = "instance1vpc01"
  }
}
