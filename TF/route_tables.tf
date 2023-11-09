resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.dev-vpc.id
  # Define routes for private subnets (e.g., backend services)

  # To route traffic within the VPC (local) and to NAT gateway for internet access
  route {
    cidr_block = "10.0.0.0/16"  # VPC CIDR
    gateway_id = aws_vpc.dev-vpc.internet_gateway_id
  }

    #  all non-local traffic from the private subnet will be routed to the NAT gateway
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dev-vpc.id
  # Define routes for public subnets (e.g., frontend resources)

  # Example: Route traffic within the VPC (local) and directly to the internet gateway
  route {
    cidr_block = "10.0.0.0/16"  # VPC CIDR
    gateway_id = aws_vpc.dev-vpc.internet_gateway_id
  }

  # Add more routes for other services (e.g., S3, CloudFront)
}

# Associate route tables with subnets
resource "aws_subnet_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_subnet_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpc.dev_vpc.internet_gateway_id
}