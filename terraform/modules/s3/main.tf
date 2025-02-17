resource "aws_s3_bucket" "stock" {
  bucket        = var.s3_stock_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "stock_procssed" {
  bucket        = var.s3_stock_bucket_processed
  force_destroy = true
}

resource "aws_s3_bucket" "script" {
  bucket        = var.s3_script_bucket
  force_destroy = true
}


resource "aws_s3_object" "stock" {
  bucket = aws_s3_bucket.stock.id
  key    = "${var.s3_stock_folder}/"
}

resource "aws_s3_object" "stock_procssed" {
  bucket = aws_s3_bucket.stock_procssed.id
  key    = "${var.s3_stock_folder}/"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.script.id
  key    = "glue_script.py"
  source = "modules/s3/glue_script.py"
}


