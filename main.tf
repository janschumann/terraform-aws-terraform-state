resource "aws_s3_bucket" "state" {
  count = local.is_associated_account ? 0 : 1

  bucket = var.bucket_name != "" ? var.bucket_name : null
  policy = data.aws_iam_policy_document.bucket.json
  acl    = "private"

  # this is important as this bucket will also contain the terraform state
  # of all terraform configurations
  versioning {
    enabled = true
  }

  tags = merge(local.default_tags, {
    Name        = var.bucket_name
    Description = "Central terraform state location"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key" "state" {
  count = local.is_associated_account ? 0 : 1

  description             = "Terraform state encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key.json

  tags = local.default_tags
}

resource "aws_kms_alias" "state" {
  count = local.is_associated_account ? 0 : 1

  target_key_id = join("", aws_kms_key.state.*.key_id)
  name          = format("alias/%s", var.kms_key_alias_name)
}

resource "aws_dynamodb_table" "state" {
  name = var.lock_table_name

  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.default_tags, {
    Name        = var.lock_table_name
    Description = "Terraform state lock table"
  })
}

resource "aws_iam_policy" "state_manager" {
  name_prefix = "TerraformStateFullAccess"
  policy      = data.aws_iam_policy_document.state_manager.json
}

resource "aws_iam_policy" "state_reader" {
  name_prefix = "TerraformStateRead"
  policy      = data.aws_iam_policy_document.state_reader.json
}

resource "aws_iam_policy" "state_writer" {
  name_prefix = "TerraformStateWrite"
  policy      = data.aws_iam_policy_document.state_writer.json
}
