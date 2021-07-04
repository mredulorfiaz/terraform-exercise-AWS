# AWS deployment with terraform
This is the first time I'm using Terraform as IaC
## Used Tools
 - Terraform
 - AWS

 ## How to use
 - Install terraform CLI
 - Run command `terraform init` to fetch provider
 - Set the values of the variables in a `.tfavars` file
 - Run the command to plan the deployment `terraform plan -var-file <name>.tfvars`
 - Apply everything with `terraform apply -var-file <name>.tfvars`


 Enjoy!