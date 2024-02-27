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


