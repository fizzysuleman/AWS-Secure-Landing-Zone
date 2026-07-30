resource "aws_vpc" "landing_zone" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

    tags = {
        Name      = "Landing Zone VPC"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }

}


# ---------------------------------------------------------
# Public subnet
# ---------------------------------------------------------
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.landing_zone.id
    cidr_block = "10.0.1.0/24"

    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"

    tags = {
        Name      = "Landing Zone Public Subnet"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}



# ---------------------------------------------------------
# Private subnet
# ---------------------------------------------------------
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.landing_zone.id
    cidr_block = "10.0.2.0/24"

    availability_zone = "us-east-1a"

    tags = {
        Name      = "Landing Zone Private Subnet"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}


# ---------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------

resource "aws_internet_gateway" "landing_zone" {
  vpc_id = aws_vpc.landing_zone.id

  tags = {
    Name      = "Landing Zone Internet Gateway"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.landing_zone.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.landing_zone.id
  }

    tags = {
        Name      = "Landing Zone Public Route Table"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}