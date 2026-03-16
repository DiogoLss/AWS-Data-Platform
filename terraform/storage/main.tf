#---MAIN BUCKET
resource "aws_s3_bucket" "data" {
  bucket = var.main_bucket_name
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

#---RETAIL BUCKET
resource "aws_s3_bucket" "retail" {
  bucket = var.retail_bucket_name
  tags   = var.common_tags
}

resource "aws_s3_object" "retail" {
  bucket = aws_s3_bucket.retail.id
  key    = var.retail_folder_name
}

resource "aws_s3_bucket_versioning" "versioning_retail" {
  bucket = aws_s3_bucket.retail.id
  versioning_configuration {
    status = var.retail_versioning_status
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "retail-bucket-config" {
  bucket = aws_s3_bucket.retail.id

  rule {
    id = "retail"
    expiration {
      days = 1
    }
    filter {
      prefix = var.retail_folder_name
    }
    status = var.retail_versioning_status
  }
}