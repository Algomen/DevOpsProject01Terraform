variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "project01"
}

variable "username" {
  description = "Username for your VM"
  default = "testuser"
}

variable "password" {
  description = "Password for your VM"
  default = "Test1234"
}

variable "numberOfVMs" {
  description = "Number of VMs to be deployed behind the load balancer. It must be between 2 and 5"
  default = 2

  validation {
    condition = var.numberOfVMs>=2 && var.numberOfVMs<=5
    error_message = "The number of VMs chosen must be betweent 2 and 5"
  }
}
