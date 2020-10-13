data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key" {
  dynamic "statement" {
    for_each = [
      for s in local.kms_key_policy_statements : merge(s["statement"], { principals = s["principals"] }) if length(s["principals"]) > 0
    ]
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      principals {
        identifiers = statement.value["principals"]
        type        = "AWS"
      }
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  dynamic "statement" {
    for_each = [
      for s in local.bucket_policy_statements : merge(s["statement"], { principals = s["principals"] }) if length(s["principals"]) > 0
    ]
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      principals {
        identifiers = statement.value["principals"]
        type        = "AWS"
      }
    }
  }
}

data "aws_iam_policy_document" "state_manager" {
  dynamic "statement" {
    for_each = local.state_manager_policy_statements
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

data "aws_iam_policy_document" "state_reader" {
  dynamic "statement" {
    for_each = local.state_reader_policy_statements
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

data "aws_iam_policy_document" "state_writer" {
  dynamic "statement" {
    for_each = local.state_writer_policy_statements
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}
