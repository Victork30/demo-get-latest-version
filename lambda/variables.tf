variable "profile_name" {
  description = "AWS profile name"
  type	      = string
  default     = "default"
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

