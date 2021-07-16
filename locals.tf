locals {
  is_associated_account = length(var.associated_accounts) == 0 || setintersection([data.aws_caller_identity.current.account_id], keys(var.associated_accounts)) == [data.aws_caller_identity.current.account_id]

  reader_principals  = distinct(concat(var.reader_principals, var.writer_principals))
  writer_principals  = distinct(var.writer_principals)
  manager_principals = distinct(var.manager_principals)

  kms_key_resources = distinct(compact(concat([var.kms_key_arn], aws_kms_key.state.*.arn)))

  use_kms_key_statement = {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  manage_kms_key_statement = {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
  kms_key_policy_statements = [
    {
      statement  = local.manage_kms_key_statement
      principals = local.manager_principals
    },
    {
      statement  = local.use_kms_key_statement
      principals = local.reader_principals
    }
  ]

  lock_table_resources = formatlist("arn:aws:dynamodb:%s:%s:table/terraform-state-lock", [var.region], data.aws_caller_identity.current.account_id)
  manage_lock_table_statement = {
    actions = [
      "dynamodb:*",
    ]
    effect    = "Allow"
    resources = local.lock_table_resources
  }
  read_lock_table_statement = {
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    effect    = "Allow"
    resources = local.lock_table_resources
  }
  write_lock_table_statement = {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable"
    ]
    effect    = "Allow"
    resources = local.lock_table_resources
  }

  bucket_name             = format("%s-terraform-state", var.bucket_name)
  bucket_folder_resources = formatlist("arn:aws:s3:::%s", [var.bucket_name])
  bucket_object_resources = formatlist("arn:aws:s3:::%s/*", [var.bucket_name])
  // TODO fine grained access control to state objects
  // bucket_object_resources_writer = formatlist("arn:aws:s3:::%s/env:/%s/*", [var.bucket_name], terraform.workspace)
  all_bucket_resources = concat(local.bucket_folder_resources, local.bucket_object_resources)
  manage_bucket_statement = {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = local.all_bucket_resources
  }
  read_bucket_objects_statement = {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    effect    = "Allow"
    resources = local.all_bucket_resources
  }
  write_bucket_objects_statement = {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    effect    = "Allow"
    resources = local.bucket_object_resources
  }
  bucket_policy_statements = [
    {
      statement  = local.manage_bucket_statement
      principals = local.manager_principals
    },
    {
      statement  = local.read_bucket_objects_statement
      principals = local.reader_principals
    },
    {
      statement  = local.write_bucket_objects_statement
      principals = local.writer_principals
    }
  ]

  state_manager_policy_statements = [
    local.manage_lock_table_statement,
    local.manage_bucket_statement,
    merge(local.manage_kms_key_statement, {
      resources = local.kms_key_resources
    })
  ]
  state_reader_policy_statements = [
    local.read_lock_table_statement,
    local.read_bucket_objects_statement,
    merge(local.use_kms_key_statement, {
      resources = local.kms_key_resources
    })
  ]
  state_writer_policy_statements = concat(local.state_reader_policy_statements, [
    local.write_bucket_objects_statement,
    local.write_lock_table_statement
  ])

  default_tags = {
    Environment = terraform.workspace
  }
}
