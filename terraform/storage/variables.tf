variable "main_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "common_tags" {
  type        = map(string)
  description = "The common tags to apply to all resources."
}

variable "retail_bucket_name" {
  type        = string
  description = "S3 bucket name I use in Udemy course."
  default     = "dsl-retail"
}

variable "retail_folder_name" {
  type        = string
  description = "S3 folder name inside the retail bucket."
  default     = "retail/"
}

variable "retail_versioning_status" {
  type        = string
  description = "Whether to enable versioning for the retail bucket."
  default     = "Enabled"
}