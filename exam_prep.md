# Terraform exam objectives

## 1. Understand infrastructure as code (IaC) concepts

### a. Explain what IaC is

Infrastructure as code (IaC) is the managing and provisioning of infrastructure through code instead of manual processes.

PERSONAL:

i.e. We can deploy infrastructure through code rather than interacting with the cloud provider's website. Infrastructure could be many different services cloud providers offer; we could deploy virtual machines in a VPC network with security groups and a load balancer, all from a configuration file. 

### b. Describe advantages of IaC patterns

Benefits of IaC:
- Speed of infrastructure management: once youve written the code which can take some time, you can then deploy the infrastructure quickly in a repeatable fashion
- Low risk of human errors
- Version control: Since you are writing code, you can commit this to e.g. GitHub and have pull requests, approvals etc
- Easy collaboration: Since the code can be in GitHub, multiple team members can collaborate on the code

PERSONAL:

Manual vs Automation:

Imagine traditional (pre-cloud) infrastructure e.g. servers in a private data center. If we needed a new VM deployed, we could provision it by going to the console and manually allocating some of the server's resources.
- This is fine if there was not a lot of infrastructure to managed or low churn (updating old infrastructure) -> Handful of large instances. 
- Nowadays, with cloud, this is not really the case any more. Instead of infrastructure lasting a long time, it now lasts days to weeks (high churn) as well as API driven infrastructure which requires a lot of management -> Many small instances
- We need a tool so that we do not have to manually manage all of this infrastructure, so instead of pointing and clicking to provision we can codify the process so that we can provision and delete the architecture as many times as we needed to. 

If a particular task is done in a repeatable manner, it must be automated!

- Advantages:
  - **Automation**: With this automated process, we could deploy more infrastructure in busy times and delete the extra infrastructure when the server is less busy with a single command. This is more useful now with cloud resources as we pay for usage, rather than paying a lump sum for a large server that we do not pay as we use it. 
  - **Versioning**: Rather than pointing and clicking we have it written down in a file and so it is documented
  - **Standardisation**: When using a 
  - **Planning**: 

For example, if we have to deploy infrastructure to dev, staging and production, we should really automate this as we dont want to essentially repeat the same task 3 times, and if needed we can resuse our deployment in the future.


## 2. Understand the purpose of Terraform (vs other IaC)

Various IaC tools: terraform, cloudformation, heat, ansible, saltstack, chef, puppet,...
They can be divided into 2 categories:
1. Orchestration (terraform, cloudformation): primarily used to create and manage infrastructure environments. e.g. REQUIREMENT: 3 servers with 4gb RAM 2vGPUs...
2. Configuration management (ansible, chef): primarily used to maintain desired configuration of systems (inside servers). e.g. REQUIREMENT: all servers must have antivirus installed

Both can deploy infrastructure, however orchestration tools should be prefered since that is what they are designed for (once the infrastructure has been deployed, then it is a good idea to use configuration management tools to configure the infrastructure)

How to choose the correct IaC tool?:
1. Is the infrastructure provider specific? e.g. AWS
2. Will there be multi cloud/hybrid cloud?
3. How well does it integrate with configuration management tools?
4. Price and Support?

PERSONAL:

Terraform allows us to create reusable code that can deploy identical sets of infrastructure in a repeatable fashion.

We can easily create and manage infrastructure.

Terraform specifically supports thousands of providers (AWS, Azure, GCP, K8, Alibaba cloud, Oracle cloud...) and you can write code to create and manage infrastructure across all the providers

### a. Explain multi-cloud and provider-agnostic benefits

### b. Explain the benefits of state

Terraform stores the state of the infrastructure (what is deployed and what isnt) that is created from the tf files. This state allows terraform to map real world resources to the existing configuration.

Each resource currently managed is stored in `terraform.tfstate` including its name and other information e.g. for an ec2 instance the ami used, the instance type... as well as other information terraform uses in the backend. When you destroy a resource, it is removed from that file. When we run `terraform plan`, terraform checks the state file and sees whats currently being managed, and anything not in there will be created after running `terraform apply`. Anything in there will be left alone (refreshed). 

(Dont edit the state file manually)

Desired state: how we code the resources in the terraform files 

Current state: the actual state of the resources deployed

`terraform plan` shows you how terraform will attempt to bring the current state to the desired state and `terraform apply` actually commits those changes

Terraform will only change the current state with the desired state resources specifically mentioned in the terraform file. FOR EXAMPLE when we create an aws_instance and do not specify a security group, terraform gives it a default one. If we then go into the AWS console, make and assign a custom security group to the instance then re run terraform apply, terraform will not change anything as the desired state matches the current state still (may have to run `terraform refresh` to update the state file)

`terraform refresh`: if we change the infrastructure manually, so not through terraform, how would terraform know about the changes made? It can't, so when you run `terraform refresh`, terraform checks the state of the infrastructure as it is and updates its state file accordingly. 
- Shouldn't really need to use it, as when you run plan or apply terraform automatically runs refresh too. 
- it can actually be dangerous. lets say you have an ec2 instance running, then change the region then run refresh, since the region is different terraform wouldn't know about the ec2 in the first region and so it would remove that from the state file (with it still running) -> can use the state backup file to fix it.
- refresh is deprecated in newer versions, but you can still refresh by running `terraform plan -refresh-only` (or apply)

## 3. Understand Terraform basics

Remember dont hardcode the access keys into your tf files -> might accidently push to github then the system is compromised

Instead:
- In the provider block you could specify the configuration and credential file paths stored somewhere else on your system (not reccomended as if your working in a team everyone will need the files saved in the same place). if these paths are not specified, terraform automatically looks at ~/.aws/config or ~/.aws/credentials on linux/mac (or %USERCONFIG%/.aws/config or credentials for windows) 
- Could also use AWS CLI (terraform still searches in the same places for the files)
- Save them as environment variables and terraform can read them

### a. Install and version Terraform providers

Installing Terraform: very simple -
- (Windows) download binary file and can run it from there (add to PATH so you can call it from anywhere)
- (Linux/MacOS) Run the given commands (could also wget urltobinary then unzip it then you can run it - again add it to PATH/binaries)

providers e.g. aws, azure...

Provider architecture:

main.tf -> terraform <-> terraform provider e.g. aws <-> aws cloud

the provider and cloud communicate through api interactions

Its important to specify the version of the provider in production e.g. your coding for windows 7, then windows 10 comes out. all your previous code will break if you don't specify the version as it will use the latest. use the terraform configuration and nested required providers block to specify the version of the provider:
```
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
```

What is `~>`?: Can choose many equality symbols:
- >=1.0 -> Greater than or equal to the version
- <=1.0 -> less than or equal to the version
- ~>1.0 -> any version in the 1.x range
- >=2.10.<=2.30 -> any version between 2.10 and 2.30
- =1.0 -> the specific version

In production its generally recommended to use `=` just to ensure the code works, stuff can change and break between these updates.

When doing `terraform init`, a `terraform.lock.hcl` file is created so that if you make a constraint like the ones above, then later on change it to outside the constraint, `terraform init` will fail as it will say the locked provider does not match the new congifuration constraint*

The lock file allows us to lock to a specific version of the provider. If a particular version is in the lock file, terraform will always choose that version even if a newer version becomes available.

*To avoid the lock you could delete the lock file and init would work again OR you could do `terraform init -upgrade` and it will work and update the lock file to match the new configuration

Should you always update to the newest version? It depends: if the provider releases a new service that you need only on the newer version, it would be a good idea to update your code, otherwise if it aint broke no point changing it.

### b. Describe plugin-based architecture

A provider is a plugin that lets Terraform manage an external API

When we run `terraform init` plugins for the provider are automatically downloaded and saved to `.terraform` e.g. `hashicorp/aws`

If you want to add another provider, specify it then run `terraform init` and plugins for it will be downloaded

### c. Write Terraform configuration using multiple providers

The core concepts, the standard syntax remain the same across all providers. All you have to do is install the plugin then refer to the documentation for the provider.

### d. Describe how Terraform finds and fetches providers

3 tiers of providers:
1. Official - owned/maintained by hashicorp
2. Partner - owned/maintained by partners of hashicorp
3. Community - owned/maintained by individual creators

Corresponding provider Namespaces:
1. hashicorp
2. e.g. mongodb
3. e.g. induviduals account e.g. gsuite

Terraform requires additional explicit source information for providers not maintained by hashicorp using a `terraform` configuration block and a nested `required_providers` block: (digitalocean is a partner) - check docs. You can still do this with official providers for greater configuration.
```
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

```

## 4. Use Terraform outside of core workflow

### a. Describe when to use `terraform import` to import existing infrastructure into your Terraform state

### b. Use `terraform state` to view Terraform state

### c. Describe when to enable verbose logging and what the outcome/value is

## 5. Interact with Terraform modules

### a. Contrast and use different module source options including the public Terraform Module Registry

### b. Interact with module inputs and outputs

### c. Describe variable scope within modules/child modules

### d. Set module version

## 6. Use the core Terraform workflow

### a. Describe Terraform workflow ( Write -> Plan -> Create )

### b. Initialize a Terraform working directory (`terraform init`)

### c. Validate a Terraform configuration (`terraform validate`)

### d. Generate and review an execution plan for Terraform (`terraform plan`)

### e. Execute changes to infrastructure with Terraform (`terraform apply`)

Can run `terraform apply -auto-approve` to avoid the user input (having to type `yes`)

Apply can fail even if plan succeeds!

### f. Destroy Terraform managed infrastructure (`terraform destroy`)

You are typically charged for running infrastructure

2 approaches to destroy infrastructure:
1. Destroy all: `terraform destroy` allows us to destroy all resources created in the folder
2. Destroy some: `terraform destroy -target resource.name` allows you to destroy a specific resource e.g. `terraform destroy -target aws_instance.myec2` (remember resource+name=unique identifier)

### g. Apply formatting and style adjustments to a configuration (`terraform fmt`)

## 7. Implement and maintain state

Currently we have been working with Terraform locally -> not great:
- We could lose all our files (e.g. if our hard drive gets corrupted)
- Not good for collaboration - how will our team members get access to our files?

Solve with centralized management - centralized reporistory
- e.g. GitHub, Bitbucket...

Remember never push your access credentials to these as they are publically accessible:
- We could store them in a seperate file outside of the git repo and reference them with string interpolation: `pass = "${file("../pass.txt")}" however this is still not a good idea. In our `terraform.tfstate`, the value of pass is explicitly stated so if they have access to the state file they have access to our credentials.
- -> use a `.gitignore` which tells git which files to ignore in your repo.
- Files to ignore:
  - `**/.terraform/*` - as it is big
  - `*.tfvars` - likely contains sensitive information
  - `*.tfstate` AND
  - `*.tfstate.*` - again contains sensitive information. should be stored remote side
  - `crash.log`
  - `override.tf` - override files are used to override values locally so no point pushing 

### a. Describe default `local` backend

Backends primarily determine where terraform will store its state - by default terraform implicitly uses a default backend called `local` to store state as a local file on disk.
- Storing the state file locally will not allow for collaboration
- We need a central backend

Ideal architecture:
1. Terraform code stored in Git repo
2. State file stored in central backend (not local)

### b. Describe state locking

When you are performing a write operation to the state file (e.g. terraform apply) terraform locks the state file
- Necessary since if while your applying someone else applies it can corrupt the state file.
- Can disable with `terraform apply -lock=false` but not reccomended.
- Can also force unlock state with `terraform force-unlock LOCKID` (see below for id). May be necessary if automatic unlocking fails however it could cause errors if someone else is holding the lock and is applying operations. therefore should only be used on your own locks.
- How does terraform lock the state file?: it creates a `.terraform.tfstate.lock.info` file which contains a lock id, the operation happening and who intitiated the operation. Once its finished, the lock file is removed.

Locking:
- Happens automatically
- If locking fails, terraform will not continue
- Not all backends support locking

### c. Handle backend and cloud integration authentication methods

Accessing state in a remote service generally requires some kind of authentication. - e.g. through environment variables or the config files.

Some backends act like plain remote disks for state files, others support locking the state while operations are being performed which helps prevent conflicts with collaboration.

For example S3 does not support state locking

### d. Differentiate remote state back end options

Terraform supports mutliple backends that allow remote service operations:
- S3
- Consul
- Azurerm
- Kubernetes
- HTTP
- ETCD

As stated, S3 does not support state locking. We need to use DynamoDB to lock the state. If we did not use DynamoDB, we would be able to perform 2 concurrent operations which is dangerous.


### e. Manage resource drift and Terraform state

### f. Describe `backend` block and cloud integration in configuration

E.g. S3:
```
terraform {
  backend "s3" {
    bucket = "mybucket" # name of bucket created in s3 (manually)
    key    = "network/terraform.tfstate" # where the state file will be stored in the bucket
    region = "eu-west-1"
  }
}
```

Now when you run terraform init it will say s3 backend initialised successfully. When you run apply, no state file will be created in your local folder, instead it will be automatically created and sent to S3.

To implement state locking for S3:
terraform {
  backend "s3" {
    bucket = "mybucket" # name of bucket created in s3 (manually)
    key    = "network/terraform.tfstate" # where the state file will be stored in the bucket
    region = "eu-west-1"
    dynamodb_table = "mytable" # name of table created in dynamodb (manually) NOTE remember to set pertition key to `LockID` as specified in documentation when creating the table
  }
}
```
If you change the backend block, you will need to rerun init, and an error will throw that you need to migrate. You can do this with `terraform init -migrate-state`, or to save the previous state `terraform init -reconfigure`.

Now when you run an operation, when you go to the dynamodb table it will show the lock similarily to the lock file.


### g. Understand secret management in state files

## 8. Read, generate, and modify configuration

Attributes: Each resource has its associated set of attributes. They are the fields in the resource block that hold the values that end up in the state file e.g. for aws_instance you have id, public ip, private ip. NOT THE ARGUMENTS. The arguments are what we write e.g. ami = "denend" (desired state) the attributes are whats in the state file (current state).

We can reference attributes with `.` e.g. aws_instance.myec2.id <- id is an attribute here. (resourcetype.name.attribute)

Cross resource: E.g. we have 2 resources, and one depends on the other. FOR EXAMPLE create an elastic IP and security group, and only open ports for that IP. do same as above, reference in the security group cidr_ipv4 = "aws_eip.myip.public_ip"
- Except actually no! need to pass a cidr block, not just an ip. So we want essentially to pass aws_eip.myip.public_ip/32.
- How? String interpolation! -> cidr_ipv4 = "${aws_eip.myip.public_ip}/32"
- This calculates the ip first, (${} is syntax for string interpolation) then appends /32, then passes that entire string to the cidr block argument. 
  - "Terraform replaces the expression inside the curly braces with its calculated value"


Reccomended folder structure in terraform:
1. Main configuration file (e.g. `main.tf`)
2. `variables.tf` file that defines all the variables
3. `terraform.tfvars` that defines value to all the variables

### a. Demonstrate use of variables and outputs

**Output values**: info about your infrastructure available on the command line and can expose this info for other terraform configurations to use
- If a user wants to create an ec2 instance AND ALSO get the public ip of it, terraform can create the ec2 and then use outputs to fetch the info of the ec2 finally printing the public ip of the ec2 to the user. 
- Use `output` code blocks:
```
output "public-ip" {
  value = aws_eip.lb.public_ip
}
```
- After running terraform apply and it finishes, the value will be printed, using the name of the block e.g. 
```
Outputs:

public-ip = "34.253.7.254"
```
Could use string interpolation to make the output more usable:
```
output "public-ip" {
  value = "https://${aws_eip.lb.public_ip}:8080"
}
```
This would print a url that we could paste into our search bar to quickly access the ec2 instance from the internet.

If you dont specify an attribute e.g. `value = aws_eip.lb` then all attributes for that resource are printed.

Can also use this output info in another terraform configuration:
- E.g. we have a.tf and b.tf. b.tf needs the public ip from a resource in a.tf, so what you can do is output the public ip for that resource then b can fetch that information to be used in its configuration. 
- Output information is saved in the tfstate file so b could fetch the information from there. 

**Variables**: Solves repeated static values by defining it in one place. Imagine you need to change the value -> unfeasible to change it in every occurence, so just change it in the variable definition and its sorted.

So the benefits would be:
1. update important values in one place rather than having to update them at every occurence, saving time and potential mistakes
2. you dont have to edit the config file, you can just edit the variable file, avoiding human error.

Try to use variables as much as possible!

Terraform input variables are used to pass values from outside the configuration file, from a variable file (can be called anything e.g. `variable.tf` or `central-location.tf`... but the standard naming convention is `variables.tf`!)

Defined as:
```
variable "app_port" {
  default = "80"
}
```
Then used as e.g. in = var.app_port

Maintianing variables in production is really important to keep code clean and reusable. Therefore Hashicorp reccomends creating a seperate file called `*.tfvars` to define all variable value in a project. (typically called `terraform.tfvars` (if only using a single tfvars file), or `dev.tfvars` or `prod.tfvars` for the different environments)

So instead you would have in `variables.tf`:
```
variable "app_port"{}

variable ...
```
And in `*.tfvars`:
```
app_port = "8080"
...
```
Why do this? Organisations can have multiple environments e.g. dev, prod, staging, and so we can have different values associated with the variables for each environment. We can then choose the `tfvars` file to use when applying e.g. `terraform apply -var-file="prod.tfvars`.
- If you don't specify the var-file flag, terraform will not know where to get the variable values and so will prompt you to input them when running plan/apply. HOWEVER, if you name the file `terraform.tfvars` then terraform will automatically take the values from that file -> this is similar to defining a variable but not giving it a value, terraform will prompt the user to give a value for it when planning/applying.
- You can still put a default value in the `variables.tf` and terraform will use it if it cant find an associated `tfvars` file, but it prioritises the `tfvars` values.

2 more ways declare variable values: through environment variables and setting through cli so in total 5 ways:
1. variable defaults
2. variable definition file (tfvars)
3. environment variables -> named TF_VAR_variableName e.g. set TF_VAR_instance_type = t2.micro, then when doing terraform plan it will use that value.
4. setting variables through cli -> `-var` flag e.g. terraform plan -var="instance_type=t2.micro"
5. prompted at planning/applying

What if we have different values for the same variable on each of these methods? Terraform loads the value in this order, and so the last one given will be the value of the variable at the end of applying:
1. Environment variables
2. tfvars file, if present
3. tfvars.json file, if present
4. any `*.auto.tfvars` or `*.auto.tfvars.json` files, processed in lexical order of their filenames (e.g. a, then b...)
5. any -var and -var-file options through cli  <-- so if all were given, this would be the value chosen
### b. Describe secure secret injection best practice

### c. Understand the use of collection and structural types

### d. Create and differentiate `resource` and `data` configuration

Resource block describes one or more infrastructure objects e.g.:
```
resource "aws_instance" "myec2" {
  ami = "..."
  ...
}
```
`aws_instance` is the resource, there can be many resources that terraform manages

A resource block declares a resource of a given type (`aws_instance`) with a given local name (`myec2`). Resource type and name together form a unique indentifier for a given resource.

You can only use resources supported by the provider you have installed the plugins for. (obviously)

### e. Use resource addressing and resource parameters to connect resources together

### f. Use HCL and Terraform functions to write configuration

## 9. Understand HCP Terraform capabilities

### a. Explain how HCP Terraform helps to manage infrastructure

### b. Describe how HCP Terraform enables collaboration and governance