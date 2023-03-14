variable "location" {
  default = "norwayeast"
}
variable "prefix" {
  default = "lt-tf-win"
}
variable "resource_group_name" {
  default = "${var.prefix}-rg"
}
variable "vnet_name" {
  default = "${var.prefix}-vnet"
}
variable "subnet_name" {
  default = "${var.prefix}-subnet"
}
variable "bastion_name" {
  default = "${var.prefix}-bastion"
}
variable "bastion_configuration" {
  default = "${var.prefix}-bastion-conf"
}
variable "security_group_name" {
  default = "${var.prefix}-nsg1"
}
variable "nic1_name" {
  default = "${var.prefix}-nic1"
}
variable "win_vm1_name" {
  default = "${var.prefix}-vm1"
}
variable "win_vm1_sku" {
  default = "2019-Datacenter"
}
variable "win_vm1_admin" {
  default = "win-admin"
}
variable "keyvault_name" {
  default = "lt-dev-kv1"
}
variable "keyvault_rg" {
  default = "lt-dev-terraform"
}
variable "keyvault_secret" {
  default = "win-vm1-password"
}
