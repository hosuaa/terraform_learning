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
resource "aws_security_group" "app_sg" {
  name        = "joshual_app_sg__allow_ssh_http_3000"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # this is how you can add a rule to the security group. ingress for inbound, egress for outbound
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 3000 for Node"
    from_port   = 3000
    to_port     = 3000
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
    Name = "joshual_app_sg__allow_ssh_http_3000"
  }

}
resource "aws_security_group" "db_sg" {
  name        = "joshual_db_sg__allow_ssh_27017"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # this is how you can add a rule to the security group. ingress for inbound, egress for outbound
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 27017 for MongoDB"
    from_port   = 27017
    to_port     = 27017
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
    Name = "joshual_db_sg__allow_ssh_27017"
  }

}
# which service
resource "aws_instance" "app_instance"{
  # which ami
	# ami = "ami-02f0341ac93c96375"
  ami = var.app_ami_id
  # which controller (micro)
	instance_type = var.app_instance_type
  # associate public ip
	associate_public_ip_address = true
  # subnet
	subnet_id = aws_subnet.app_subnet.id
  # give the security group
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # name
	tags = {
		Name = "tech258-joshual-terraform-app"
	}
}

resource "aws_instance" "db_instance" {
  ami = var.app_ami_id
  instance_type = var.app_instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.db_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "tech258-joshual-terraform-db"
  }
  
}

provider "github" {
  token = var.github_token
}
# create github repo
resource "github_repository" "iac_github_automated_repo" {
  name        = "IaC-github-automated-repo"
  description = "Automated repository creation with Terraform"
  visibility  = "public"
}