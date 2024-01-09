########################################################
# Example for Basic Infrastructure Provisioning on AWS #
########################################################

#- Networking -----------------------------------

resource "aws_vpc" "my-vpc-01" {
  cidr_block = var.vpccidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "my-vpc-01"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc-01.id
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.my-vpc-01.id
  cidr_block = var.pubsubcidr
}

resource "aws_subnet" "privsub" {
  vpc_id     = aws_vpc.my-vpc-01.id
  cidr_block = var.privsubcidr
}

resource "aws_route_table" "rt01" {
  vpc_id = aws_vpc.my-vpc-01.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "rt02" {
  vpc_id = aws_vpc.my-vpc-01.id # where does RT reside

  route { 
    cidr_block = "0.0.0.0/0" # source
    nat_gateway_id = aws_nat_gateway.natgateway.id # destination
  }
}

resource "aws_route_table_association" "rtassoc2" {
  subnet_id      = aws_subnet.privsub.id
  route_table_id = aws_route_table.rt02.id
}

resource "aws_route_table_association" "rtassoc" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.rt01.id
}

#- NAT ----------------------------------------

resource "aws_eip" "my-eip" {
  domain           = "vpc"
  public_ipv4_pool = "amazon" # Get PubIP from Amazon Address pool
  depends_on                = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "gw-NAT"
    }
}

#- DNS ---------------------------------------

resource "aws_route53_zone" "private" {
  name = "develop.internal"

  vpc {
    vpc_id = aws_vpc.my-vpc-01.id
  }
}

resource "aws_route53_record" "webserver" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "webserver.develop.internal"
  type    = "A"
  ttl     = 300
  records = [aws_instance.vm01.private_ip]
}

resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "database.develop.internal"
  type    = "A"
  ttl     = 300
  records = [aws_instance.vm02.private_ip]
}

resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name          = aws_route53_zone.private.name
  domain_name_servers  = ["AmazonProvidedDNS"]
  netbios_node_type    = 2

  tags = {
    Name = "dhcp-opts"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.my-vpc-01.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
}

#- Compute -----------------------------------------------

resource "aws_instance" "vm01" {
    ami = var.instance_ami
    instance_type = var.instance_type
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.sg01.id]
    associate_public_ip_address = true
    subnet_id = aws_subnet.pubsub.id
    
    tags = {
        Name = "vm01"
    }
}

resource "aws_instance" "vm02" {
    ami = var.instance_ami
    instance_type = var.instance_type
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.sg01.id]
    associate_public_ip_address = false
    subnet_id = aws_subnet.privsub.id
    
    tags = {
        Name = "vm02"
    }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.keyname
  public_key = var.pubkey 
}

resource "aws_security_group" "sg01" {
  name        = "Security Group HTTPS/SSH/ICMP"
  description = "Security Group for ingress and egress"
  vpc_id      = aws_vpc.my-vpc-01.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  # HTTP-Zugriff
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port   = 8   # ICMP echo request
    to_port     = -1  # -1 represents all ICMP types
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#- Outputs -------------------------------------------

output "vm01_public_ip" { 
    value = [aws_instance.vm01.public_ip]
}

