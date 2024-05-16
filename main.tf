# create ec2 instance on cloud
#HCL syntax - key = value
# which part of aws
provider "aws"{

	region = "eu-west-1"
}
# RUN terraform init AT THIS STAGE (DONT DO BELOW UNTIL YOU RUN)

# aws-access-key = fnerf
# aws-secret-key = erjge  these DONT HARDCODE - instead set them as environment variables
# dont push to github until we make a .gitignore (as one of these files will contain the secret keys)

# run terraform plan to check everything

# then run terraform apply -> type yes -> instance is now launched
# run terraform destroy -> yes -> terminates the instance

# run terraform to see a list of commands

# main is the vpc_id
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "joshual-vpc"
  }

}

resource "aws_subnet" "app_subnet" {
# can use this to refer to the vpc above (since we named it "main") 
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "joshual-app-subnet"
  }
}

resource "aws_subnet" "db_subnet" {
# can use this to refer to the vpc above (since we named it "main")
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/24"

  tags = {
    Name = "joshual-db-subnet"
  }
}

# create security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

#security group rules (22, 80, 3000)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_subnet.app_subnet.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_subnet.app_subnet.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_3000" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_subnet.app_subnet.cidr_block
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

# which service
resource "aws_instance" "app_instance"{
# which ami
	ami = "ami-02f0341ac93c96375"
# which controller (micro)
	instance_type = "t2.micro"
# associate public ip
	associate_public_ip_address = true
# subnet
	subnet_id = aws_subnet.app_subnet.id

# name
	tags = {
		Name = "tech258-joshual-terraform-app"
	}
}