############################################
# S3 Bucket pour Velero
############################################
resource "aws_s3_bucket" "velero_bucket" {
  bucket = "eshop-tf-velero-bucket-asmaa"

  tags = {
    Name    = "velero-bucket"
    Project = "Velero-project"
  }
}


############################################
# Helm Release pour Velero
############################################
resource "helm_release" "velero" {
  name             = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts/"
  chart            = "velero"
  version          = "7.1.5"
  namespace        = "velero"
  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      access_key        = aws_iam_access_key.valero.id
      secret_access_key = aws_iam_access_key.valero.secret
      bucket_name       = aws_s3_bucket.velero_bucket.bucket
      region            = "eu-west-3"
    })
  ]
}

############################################
# IAM User et Access Policy pour Velero
############################################
resource "aws_iam_user" "valero" {
  name = "valero-user"

  tags = {
    Project = "Velero-project"
  }
}

resource "aws_iam_user_policy" "valero" {
  name = "valero-policy"
  user = aws_iam_user.valero.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.velero_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.velero_bucket.bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_access_key" "valero" {
  user = aws_iam_user.valero.name
}
