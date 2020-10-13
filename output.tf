output "bucket" {
  description = "The name of the terraform state bucket"
  value       = var.bucket_name
}

output "kms_key_arn" {
  description = "The kms key to encrypt the terraform state bucket content with"
  value       = local.kms_key_resources[0]
}

output "state_manager_policy_arn" {
  description = "The arn of the policy that grants full access to terraform state resources"
  value       = aws_iam_policy.state_manager.arn
}

output "state_reader_policy_arn" {
  description = "The arn of the policy that grants read access to terraform state resources"
  value       = aws_iam_policy.state_reader.arn
}

output "state_writer_policy_arn" {
  description = "The arn of the policy that grants write access to terraform state resources"
  value       = aws_iam_policy.state_writer.arn
}
