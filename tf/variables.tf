variable "profile_name" {
  description = "AWS profile name"
  type	      = string
  default     = "your_company_name"
}

variable "path_file_credentials" {
  description = "AWS credential file location"
  type        = string
  default     = "~/.aws/credentials"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  default     = "10.102.0.0/16"
}

