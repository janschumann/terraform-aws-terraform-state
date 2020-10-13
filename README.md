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
| terraform | ~> 0.13 |
| aws | ~> 3.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| associated\_accounts | A map of associated accounts in the form <account\_id> => <account\_name>-<environment> | `map(string)` | `{}` | no |
| bucket\_name | The name of the state bucket | `string` | n/a | yes |
| kms\_key\_alias\_name | The alias name of the state kms key | `string` | `"terraform-state"` | no |
| kms\_key\_arn | The arn of the encryption key. If not provided and in main account, the key will be created | `string` | `""` | no |
| lock\_table\_name | The name of the state lock table | `string` | `"terraform-state"` | no |
| manager\_principals | A list of principals that get full access to the state bucket and kms key | `list(string)` | n/a | yes |
| reader\_principals | A list of principals that get read access to the state bucket | `list(string)` | `[]` | no |
| region | The region in which the lock table will be provisioned | `string` | n/a | yes |
| writer\_principals | A list of principals that get write access to the state bucket | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | The name of the terraform state bucket |
| kms\_key\_arn | The kms key to encrypt the terraform state bucket content with |
| state\_manager\_policy\_arn | The arn of the policy that grants full access to terraform state resources |
| state\_reader\_policy\_arn | The arn of the policy that grants read access to terraform state resources |
| state\_writer\_policy\_arn | The arn of the policy that grants write access to terraform state resources |

