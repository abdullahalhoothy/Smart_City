resource "aws_s3_bucket" "spark_stream_data" {
  bucket = "spark-streaming-data1"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.spark_stream_data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.spark_stream_data]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.spark_stream_data.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement":[
        {
            "Effect":"Allow",
            "Principal":"*",
            "Action":[
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::spark-streaming-data1/*"
        }
    ]
  })
  depends_on = [aws_s3_bucket.spark_stream_data]
}

resource "aws_iam_user" "user_resource" {
  name = "abdulah"
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user_resource.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  depends_on = [aws_iam_user.user_resource]
}

resource "aws_iam_user_policy_attachment" "s3_full_access" {
  user       = aws_iam_user.user_resource.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  depends_on = [aws_iam_user.user_resource]
}

resource "aws_iam_user_policy_attachment" "glue_console_full_access" {
  user       = aws_iam_user.user_resource.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  depends_on = [aws_iam_user.user_resource]
}

resource "aws_iam_user_policy_attachment" "user_change_password" {
  user       = aws_iam_user.user_resource.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  depends_on = [aws_iam_user.user_resource]
}



resource "aws_glue_catalog_database" "gluecatalog_res" {
  name = "catalogdatabase"
}

resource "aws_iam_role" "glue_crawler_role" {
  name = "GlueCrawlerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Sid = ""
      },
    ]
  })
  
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role for AWS Glue crawler"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",

  ]
}

# resource "aws_iam_policy_attachment" "policy_attach" {
#   for_each = toset(var.policy_arns)

#   name       = "policy-${each.key}"
#   roles      = [aws_iam_role.glue_crawler_role.name]
#   policy_arn = each.value
# }

resource "aws_iam_role_policy_attachment" "role_attach" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = each.value

  depends_on = [aws_iam_role.glue_crawler_role]
}


resource "aws_glue_crawler" "gluecralwer_res" {
  database_name = aws_glue_catalog_database.gluecatalog_res.name
  name          = "glue_crawler_1"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.spark_stream_data.bucket}/data/"
    exclusions = [
      "_spark_metadata",
      "_spark_metadata/**",
      "**/_spark_metadata",
      "**spark_metadata**"]
  }

  depends_on = [
    aws_glue_catalog_database.gluecatalog_res,
    aws_iam_role.glue_crawler_role,
    aws_iam_role_policy_attachment.role_attach
    ]
}

