terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"  # Remplacez par la région de votre choix
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # CIDR du VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

# Passerelle Internet (Internet Gateway)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainInternetGateway"
  }
}

# Sous-réseau 1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  # CIDR pour le premier sous-réseau
  availability_zone       = "eu-west-3a"    # Remplacez par une zone de disponibilité disponible
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-1"
  }
}

# Sous-réseau 2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"  # CIDR pour le deuxième sous-réseau
  availability_zone       = "eu-west-3b"    # Remplacez par une autre zone de disponibilité
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-2"
  }
}

# Sous-réseau 3
resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"  # CIDR pour le troisième sous-réseau
  availability_zone       = "eu-west-3c"    # Remplacez par une autre zone de disponibilité
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-3"
  }
}

# Importation de la clé SSH publique
resource "aws_key_pair" "my_key" {
  key_name   = "my-terraform-key"
  public_key = file("/home/ubuntu/.ssh/my-terraform-key.pub")  # Remplacez par le chemin de votre clé publique
}

# Groupe de sécurité
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permet tout le trafic sortant
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSH_HTTP_SG"
  }
}

# Instance 1 (attachée au sous-réseau 1)
resource "aws_instance" "example1" {
  ami           = "ami-06e02ae7bdac6b938"  # Remplacez par l'AMI souhaitée
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  key_name      = aws_key_pair.my_key.key_name  # Associer la clé SSH
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]  # Utilisation de l'ID du groupe de sécurité

  tags = {
    Name = "Instance-1"
  }
}

# Instance 2 (attachée au sous-réseau 2)
resource "aws_instance" "example2" {
  ami           = "ami-06e02ae7bdac6b938"  # Remplacez par l'AMI souhaitée
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet2.id
  key_name      = aws_key_pair.my_key.key_name  # Associer la clé SSH
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]  # Utilisation de l'ID du groupe de sécurité

  tags = {
    Name = "Instance-2"
  }
}

# Instance 3 (attachée au sous-réseau 3)
resource "aws_instance" "example3" {
  ami           = "ami-06e02ae7bdac6b938"  # Remplacez par l'AMI souhaitée
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet3.id
  key_name      = aws_key_pair.my_key.key_name  # Associer la clé SSH
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]  # Utilisation de l'ID du groupe de sécurité

  tags = {
    Name = "Instance-3"
  }
}

# Bucket S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-terraform22"

  # Vous pouvez aussi ajouter d'autres options comme versioning, logging, etc.
}

# Outputs pour récupérer les IP publiques des instances EC2
output "instance1_public_ip" {
  value = aws_instance.example1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.example2.public_ip
}

output "instance3_public_ip" {
  value = aws_instance.example3.public_ip
}
