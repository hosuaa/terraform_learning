# Terraform

Terraform is an IaC software that allows us to automate deploying instances with code. This means rather than having to navigate to AWS -> EC2 then fill in the information, we can instead codify it.

This is incredibly useful if we want to launch multiple instances, as we know that can take a while doing it through the browser interface. 

## Installing Terraform

Download from `https://developer.hashicorp.com/terraform/install?product_intent=terraform`

For windows, we want to select AMD64 (64 bit).

Once downloaded, put it in its own folder, I put it in my `User` directory. 

Now add terraform to PATH:
1. search `env` -> `edit system variables` -> `Environment variables`
2. In your system variables, edit Path, then add a new line to the folder that contains terraform e.g. `C:\Users\joshi\terraform\`
3. Check installation by opening a new cmd and running terraform --version

![alt text](image.png)

## Using Terraform to load a new EC2 instance with code

We will create a terraform file that after running will load up our app instance

1.  We need to link to terraform our AWS credentials, so that it can run a new instance under our account. We will do this by providing our access key and secret key.
    - However, we DO NOT want to hardcode these into our terraform file as that is a security risk.
    - Instead, we will add these as environment variables with the correct name so that terraform knows where to look for them
    - Similarily to installing terraform, navigate to environment variables. Add two user variables: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_KEY` and put in their corresponding values
2. Now open Git Bash in administrator
3. Since terraform was added to our path, we can run terraform anywhere. Create a directory for your terraform files and in that create a `main.tf` (in the folder run `nano main.tf`)
4. We can start writing the terraform script

### Script

Comments start with `#`

The syntax uses named code blocks, then HCL (so key = value pairs. The values are surrounded by "")

Start the script with the cloud provider for the instance, and the region in the cloud provider:

```tf
provider "aws"{

        region = "eu-west-1"
}
```

After doing this, run `terraform init`. You should see this:

![alt text](image-1.png)

Now provide the information for the kind of service you want from the cloud provider, and how that service will be implemented:

```tf
# which service (ec2 instance)
resource "aws_instance" "app_instance"{
# which ami
        ami = "ami-02f0341ac93c96375"
# which controller (micro)
        instance_type = "t2.micro"
# associate public ip
        associate_public_ip_address = true
# name
        tags = {
                Name = "tech258-joshual-terraform-app"
        }
}
```

:boom: :warning: **IMPORTANT** :boom: :warning:  

- NEVER hardcode your credentials in this file. ALWAYS set your credentials as environment variables
- DO NOT PUSH the folder containing the terraform script to GitHub until you make the correct `.gitignore` file. This is because additional files are created that store the access credentials as backup, and so they would be exposed if pushed. 

Now we can run `terraform plan`. This is similar to right before launching an instance where we can see a summary of what will be made:

![alt text](image-2.png)

If all looks good, run `terraform apply` then type `yes`. This effectively launches the instance

![alt text](image-3.png)

Afterwards if we go to our instances on AWS, we should see an instance loading with the name given.

To terminate the instance, run `terraform destroy`.

For more commands, run `terraform`.
