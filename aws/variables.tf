# i have secrets stored in aws\secrets.auto.tfvars as below
#  access_key = "********************"
#  secret_key = "*******************************************"

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}
