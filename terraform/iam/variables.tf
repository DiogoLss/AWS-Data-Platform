variable "project" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "bucket_arn" {
  description = ""
  type        = string
}