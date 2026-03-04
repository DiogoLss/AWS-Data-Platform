variable "aws_region" {
  type        = string
  description = "The AWS region to create these resources in."
}

variable "profile" {
  type        = string
  description = "The AWS CLI profile to use for credentials."
}

variable "environment" {
  type        = string
  description = "The environment to deploy the resources."
}
