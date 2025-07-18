resource "aws_vpc" "web-app" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "web-app"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.web-app.id
  tags = {
    Name = "web-app-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for idx, az in var.availability_zones :
    az => {
      cidr = var.public_subnet_cidrs[idx]
    }
  }

  vpc_id                  = aws_vpc.web-app.id
  cidr_block              = each.value.cidr
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, az in var.availability_zones :
    az => {
      cidr = var.private_subnet_cidrs[idx]
    }
  }

  vpc_id            = aws_vpc.web-app.id
  cidr_block        = each.value.cidr
  availability_zone = each.key

  tags = {
    Name = "private-subnet-${each.key}"
    Tier = "private"
  }
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "nat-gateway-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.web-app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.web-app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = {
    Name = "private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}