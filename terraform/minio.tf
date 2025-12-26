provider "minio" {
  minio_server   = "${local.target_ip}:9000"
  minio_user = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = false
}

resource "minio_s3_bucket" "bucket" {
  bucket = "todo-app-bucket"
  acl    = "private"
  force_destroy = true
}

resource "minio_iam_user" "app_user" {
  name = "todo-app-service"
}

resource "minio_iam_service_account" "app_user_creds" {
  target_user = minio_iam_user.app_user.name
  depends_on = [ minio_s3_bucket.bucket, docker_container.minio ]
}

resource "minio_iam_policy" "app_policy" {
  name   = "app-storage-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}",
          "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "developer_policy_attachment" {
  user_name   = minio_iam_user.app_user.name
  policy_name = minio_iam_policy.app_policy.name
}