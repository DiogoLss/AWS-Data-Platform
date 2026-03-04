resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
  tags   = var.common_tags
}

resource "aws_s3_object" "landing" {
  bucket = aws_s3_bucket.data.id
  key    = "landing/"
}

resource "aws_s3_object" "raw" {
  bucket = aws_s3_bucket.data.id
  key    = "raw/"
}