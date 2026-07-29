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