provider "aws" {
  region = "us-east-2"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-jf"

# Prevent accidental deletion of the bucket and its contents.
  lifecycle {
    prevent_destroy = true
  }
}
# Enable versioning so you can see the full history of changes to your state file.
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}
# Enable server-side encryption to protect the state file at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}
#explicitly deny public access to the bucket and its contents.
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks-jf"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
    }
}

/*
terraform {
  backend "s3" {
    #Replace with your bucket name and DynamoDB table name
    bucket = "terraform-up-and-running-state-jf"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

    #Replace with your DynamoDB table name
    dynamodb_table = "terraform-up-and-running-locks-jf"
        encrypt = true
  }
}
/*/

output "s3_bucket_arn" {
    description = "The ARN of the S3 bucket used for Terraform state storage"
    value = aws_s3_bucket.terraform_state.arn
}
output "dynamodb_table_name" {
    description = "The name of the DynamoDB table used for Terraform state locking"
    value = aws_dynamodb_table.terraform_locks.name
}
# Partial configuration. The other settings (e.g., bucket, region, etc.) would be provided in a separate file (e.g., backend.hcl) or via command-line arguments.# Partial configuration. The other settings (e.g., bucket, region, etc.) would be provided in a separate file (e.g., backend.hcl) or via command-line arguments.
terraform {
  backend "s3" {
    key = "example/terraform.tfstate"
    encrypt = "true"
  }
}
