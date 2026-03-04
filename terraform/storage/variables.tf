variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "common_tags" {
  type        = map(string)
  description = "The common tags to apply to all resources."
}