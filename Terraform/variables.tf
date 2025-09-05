
# Provide VM Basic Details
variable "az_vm_name" {
    type = string
    default = "azwebvm01"
}

variable "az_resource_group_name" {
    type = string
    default = "azwebtest"
}

variable "az_region" {
    type = string
    default = "Central US"
}

variables "your_current_public_ip" {
    type = string
}

variables "admin_username" {
    type = string
    default = "azadmin"
}

variables "admin_password" {
    type = string
}