# skills share
Skill assessment repository for the Cloud Security Deployment Engineer Position.

Please note:
* Answers provided in Part 1 document are assuming an Azure Cloud environment, with relative cloud products and features within the solution.
* The IaC engine provided in Part 3 is Terraform and should follow guidelines for Terraform deployment to your given Azure cloud:

  Steps for Configuring a Windows PC for Terraform and Deploying TF VM.
  1. Install PowerShell 7 and Install/Import the Az module.
     a. Install PS7 - https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows
     b. From a PowerShell command prompt with elevated permissions:
       i. Type: "Install-Module -Name Az" press enter. Press "A" then enter to accept all.
       ii. Type: "Import-Module -Name Az" to import the Azure cmdlets are available for this session.
  3. Install Azure CLI on your machine, as it contains the authentication mechanism required by Terraform -
       https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
  4. Terraform Install File for Windows -
     https://developer.hashicorp.com/terraform/install
  5. Authenticate Terraform to your Azure environment using one of the methods here - 
    https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#2-authenticate-terraform-to-azure
  6. Download the Terraform folder from the repo, moving it to c:\, then from a new elevated powershell window, navigate to the c:\Terraform directory.
  7. Initialize Terraform CLI - type: "terraform init -upgrade"
  8. Create a tfplan from the terraform files - type: "terraform -out main.tfplan
  9. Apply the terraform plan - type: terraform apply main.tfplan
  10. Retrieve VMs IP to verify the deployment - type "echo $(terraform output -raw public_ip_address)
  11. From a browser navigate to the VM's IP and ensure that a basic IIS page shows.
  12. Clean up resources:
      a. type: "terraform plan -destroy -out main.destroy.tfplan"
      b. type: "terraform apply main.destroy.tfplan"
