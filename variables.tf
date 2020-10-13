variable "region" {
  type        = string
  description = "The region in which the lock table will be provisioned"
}

variable "bucket_name" {
  type        = string
  description = "The name of the state bucket"
}

variable "lock_table_name" {
  type        = string
  description = "The name of the state lock table"
  default     = "terraform-state"
}

variable "kms_key_alias_name" {
  type        = string
  description = "The alias name of the state kms key"
  default     = "terraform-state"
}

variable "kms_key_arn" {
  type        = string
  description = "The arn of the encryption key. If not provided and in main account, the key will be created"
  default     = ""
}

variable "manager_principals" {
  type        = list(string)
  description = "A list of principals that get full access to the state bucket and kms key"
}

variable "reader_principals" {
  type        = list(string)
  description = "A list of principals that get read access to the state bucket"
  default     = []
}

variable "writer_principals" {
  type        = list(string)
  description = "A list of principals that get write access to the state bucket"
  default     = []
}

variable "associated_accounts" {
  type        = map(string)
  description = "A map of associated accounts in the form <account_id> => <account_name>-<environment>"
  default     = {}
}
