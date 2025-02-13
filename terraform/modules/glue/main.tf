resource "aws_iam_role" "glue" {
  name = "${var.name}-glue-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow",
        Principal : {
          Service : "glue.amazonaws.com"
        },
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy1" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole"
}

resource "aws_iam_role_policy_attachment" "policy2" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "policy3" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_glue_catalog_database" "catalog_db" {
  name = "${var.name}-catalog-db"
}

resource "aws_glue_catalog_table" "catalog_table" {
  name          = "streaming_data"
  database_name = aws_glue_catalog_database.catalog_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    "skip.header.line.count" = 1
    "exclusions"             = "s3://${var.s3_stock_bucket_processed}/${var.s3_stock_folder}/_spark_metadata/**"
    "classification"         = "csv"
    "delimiter"              = ","
    "areColumnsQuoted"       = "false"
    "typeOfData"             = "file"
    "compressionType"        = "none"
    "columnsOrdered"         = "true"
  }

  storage_descriptor {
    location      = "s3://${var.s3_stock_bucket_processed}/${var.s3_stock_folder}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "time"
      type = "bigint"
    }
    columns {
      name = "open"
      type = "double"
    }
    columns {
      name = "high"
      type = "double"
    }
    columns {
      name = "low"
      type = "double"
    }
    columns {
      name = "close"
      type = "double"
    }
    columns {
      name = "volume"
      type = "double"
    }
    columns {
      name = "symbol"
      type = "string"
    }
    columns {
      name = "event_time"
      type = "bigint"
    }
  }
}


resource "aws_glue_job" "glue" {
  name              = "${var.name}-glue-job"
  role_arn          = aws_iam_role.glue.arn
  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  command {
    script_location = "s3://${var.s3_script_bucket}/glue_script.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--enable-spark-ui"     = "true"
    "--s3_bucket"           = "${var.s3_stock_bucket}"
    "--s3_folder"           = "${var.s3_stock_folder}"
    "--catalog_database"    = "${aws_glue_catalog_database.catalog_db.name}"
    "--catalog_table"       = "${aws_glue_catalog_table.catalog_table.name}"
  }
}

resource "aws_glue_trigger" "schedule" {
  name     = "${var.name}-glue-schedule"
  schedule = "cron(0/5 * * * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.glue.name
  }
}
