# AWS Terraform state

This module manages resources for terraform state management.

* s3 bucket 
* kms key
* dynamoDB table for state locking
* a set of policies for state access
  * state-manager
  * state-reader
  * state-writer 

## Features

Supports multi account setup, where the s3 Bucket and KMS key
are located in a central account and the associated accounts are 
added to KMS key and bucket policies.  

## Usage

```hcl
data "aws_iam_role" "manager" {
  name = "tf-state-manager"
}

module "state" {
  source = "janschumann/terraform-aws-terraform-state"

  region      = "eu-central-1"
  bucket_name = "your-org-terraform-state"
  kms_key_arn = "" // add the arn of the created kms key after first deployment 

  manager_principals = [
    data.aws_iam_role.manager.arn
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.state_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.state_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.state_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associated_accounts"></a> [associated\_accounts](#input\_associated\_accounts) | A map of associated accounts in the form <account\_id> => <account\_name>-<environment> | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the state bucket | `string` | n/a | yes |
| <a name="input_kms_key_alias_name"></a> [kms\_key\_alias\_name](#input\_kms\_key\_alias\_name) | The alias name of the state kms key | `string` | `"terraform-state"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The arn of the encryption key. If not provided and in main account, the key will be created | `string` | `""` | no |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | The name of the state lock table | `string` | `"terraform-state"` | no |
| <a name="input_manager_principals"></a> [manager\_principals](#input\_manager\_principals) | A list of principals that get full access to the state bucket and kms key | `list(string)` | n/a | yes |
| <a name="input_reader_principals"></a> [reader\_principals](#input\_reader\_principals) | A list of principals that get read access to the state bucket | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the lock table will be provisioned | `string` | n/a | yes |
| <a name="input_writer_principals"></a> [writer\_principals](#input\_writer\_principals) | A list of principals that get write access to the state bucket | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The name of the terraform state bucket |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The kms key to encrypt the terraform state bucket content with |
| <a name="output_state_manager_policy_arn"></a> [state\_manager\_policy\_arn](#output\_state\_manager\_policy\_arn) | The arn of the policy that grants full access to terraform state resources |
| <a name="output_state_reader_policy_arn"></a> [state\_reader\_policy\_arn](#output\_state\_reader\_policy\_arn) | The arn of the policy that grants read access to terraform state resources |
| <a name="output_state_writer_policy_arn"></a> [state\_writer\_policy\_arn](#output\_state\_writer\_policy\_arn) | The arn of the policy that grants write access to terraform state resources |
