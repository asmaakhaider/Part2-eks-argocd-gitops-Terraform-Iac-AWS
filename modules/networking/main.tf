### Creation du VPC 
resource "aws_vpc" "proget_vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.namespace}-vpc"
  }
}

### Creation des 2 sous-réseaux publics pour les serveurs
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.proget_vpc.id
  cidr_block              = var.cidr_public_subnet_a
  map_public_ip_on_launch = true
  availability_zone       = var.az_a

  tags = {
    Name = "${var.namespace}-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.proget_vpc.id
  cidr_block              = var.cidr_public_subnet_b
  map_public_ip_on_launch = true
  availability_zone       = var.az_b

  tags = {
    Name = "${var.namespace}-public-subnet-b"

  }
}

### Creation des 2 sous-réseaux privés pour les serveurs
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.proget_vpc.id
  cidr_block        = var.cidr_private_subnet_a
  availability_zone = var.az_a

  tags = {
    Name = "${var.namespace}-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.proget_vpc.id
  cidr_block        = var.cidr_private_subnet_b
  availability_zone = var.az_b

  tags = {
    Name = "${var.namespace}-private-subnet-b"
  }
}

##################################################### FIN

### Créer une Internet Gateway pour notre VPC
resource "aws_internet_gateway" "proget_igateway" {
  vpc_id = aws_vpc.proget_vpc.id

  tags = {
    Name = "${var.namespace}-igateway"
  }
}

### Créer une table de routage pour les sous-réseaux publics
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.proget_vpc.id # Correction ici, utilisation de proget_vpc

  tags = {
    Name = "${var.namespace}-public-routetable"
  }
}

### Créer une route dans la table de routage, pour accéder au public via la passerelle Internet
resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.proget_igateway.id
  depends_on             = [aws_internet_gateway.proget_igateway]

}

resource "aws_route_table_association" "rta_subnet_association_puba" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rtb_public.id
  depends_on     = [aws_route.route_igw]
}

resource "aws_route_table_association" "rta_subnet_association_pubb" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.rtb_public.id
  depends_on     = [aws_route.route_igw]

}
##################################################### FIN

### Créer une passerelle NAT pour le sous-réseau public A et une IP élastique
resource "aws_eip" "eip_public_a" {
}

resource "aws_nat_gateway" "nat_public_a" {
  allocation_id = aws_eip.eip_public_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "${var.namespace}-nat-public-a"
  }
}

### Créer une table de routage pour un sous-réseau privé
resource "aws_route_table" "rtb_private_a" {
  vpc_id = aws_vpc.proget_vpc.id

  tags = {
    Name = "${var.namespace}-private-routetable-a"
  }
}

### Créer une route vers la passerelle NAT
resource "aws_route" "route_private_nat_a" { # nom de la route
  route_table_id         = aws_route_table.rtb_private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_public_a.id
}

### Associer un sous-réseau privé A à la table de routage
resource "aws_route_table_association" "rta_subnet_association_privatea" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.rtb_private_a.id
}


##################################################### FIN

### Créer une passerelle NAT pour le sous-réseau public B et une IP élastique
resource "aws_eip" "eip_public_b" {
}

resource "aws_nat_gateway" "nat_public_b" {
  allocation_id = aws_eip.eip_public_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "${var.namespace}-nat-public-b"
  }
}

### Créer une table de routage pour un sous-réseau privé
resource "aws_route_table" "rtb_private_b" {
  vpc_id = aws_vpc.proget_vpc.id

  tags = {
    Name = "${var.namespace}-private-routetable-b"
  }
}

### Créer une route vers la passerelle NAT
resource "aws_route" "route_private_nat_b" {
  route_table_id         = aws_route_table.rtb_private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_public_b.id
}

### Ajouter un sous-réseau privé B à la table de routage
resource "aws_route_table_association" "rta_subnet_association_privateb" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.rtb_private_b.id
}

##################################################### FIN


