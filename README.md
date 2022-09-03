# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Log into your Azure Account
2. Open the command line and change current directory to the project folder
3. Assign the policy to your Azure subscription to deny creation of resources without tags. For that, type the following commands in the CLI:
  > az policy definition create --name tagging-policy --rules policy2.json
  > az policy assignment create --policy tagging-policy
  
  You should see something like this:
  <img width="626" alt="Policy assigned" src="https://user-images.githubusercontent.com/62774791/188282105-46e031be-8695-4515-ab38-b8ba455b714d.png">


4. Import the image template to Azure. For that, type the following commands in the CLI:
  > packer build server-packer-template.json

5. Deploy the infrastructure, selecting the number of VMs that will sit behind your load balancer, your username and your password. These variables are defined in the file vars.tf, so you should feel free to open the file and customize to your project needs, adjusting the default values, as well as the min and max possible number of VMs.
  > terraform init
  > terraform plan
  > terraform apply

You should see something like this:
![Output terraform apply](https://user-images.githubusercontent.com/62774791/188282118-3e9ceecb-894f-4c3d-948e-723a2719187f.png)


### Output
type "terraform show" in your CLI or go to the azure portal to see the new resources deployed. There your should find:
  - 1 Virtual Network
  - 1 Security securityGroup
  - 1 Load Balancer
  - 1 Public IP
  - x VMs
  - x Network network interfaces
  - x Disks
Where x is the number of VMs that you specify at deployment time
