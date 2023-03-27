variable "location" {
  default = "norwayeast"
}
variable "resource_group_name" {
  default = "lt-tf-win-rg"
}
variable "vnet_name" {
  default = "lt-tf-win-vnet"
}
variable "subnet_name" {
  default = "lt-tf-win-subnet"
}
variable "public_ip_name" {
  default = "lt-tf-win-ip1"
}
variable "bastion_name" {
  default = "lt-tf-win-bastion"
}
variable "bastion_configuration" {
  default = "lt-tf-win-bastion-conf"
}
variable "security_group_name" {
  default = "lt-tf-win-nsg1"
}
variable "nic1_name" {
  default = "lt-tf-win-nic1"
}
variable "win_vm1_name" {
  default = "lt-tf-win-vm1"
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
variable "ad_domainname" {
  default = "larzytech.com"
}
variable "ad_domaindn" {
  default = "CN=larzytech,DN=com"
}