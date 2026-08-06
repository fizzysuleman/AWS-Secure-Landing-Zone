
#Public Security Group
resource "aws_security_group" "public" {
    name        = "landing-zone-public-sg"
    description = "Security group for public access to the landing zone"
    vpc_id      = aws_vpc.landing_zone.id

    ingress {
        description = "Allow HTTP access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTPS access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name      = "Landing Zone Public Security Group"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}

# Private Security Group
resource "aws_security_group" "private" {
    name        = "landing-zone-private-sg"
    description = "Security group for private access to the landing zone"
    vpc_id      = aws_vpc.landing_zone.id


    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name      = "Landing Zone Private Security Group"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}