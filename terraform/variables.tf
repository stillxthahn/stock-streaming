variable "environment_name" {
  default = "dev"
}
variable "name" {
  default = "stockstreaming"
}

variable "prefix" {
  default = "dev"
}

variable "separator" {
  default = "-"
}

variable "region" {
  default = "us-east-1"
}

variable "s3_stock_folder" {
  default = "streaming_data"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}


# EXPORT
# export TF_VAR_region="region"
# export TF_VAR_access_key="access_key"
# export TF_VAR_secret_key="secret_key"



