# backend.hcl
bucket = "terraform-up-and-running-state-jf"
region = "us-east-2"
dynamodb_table = "terraform-up-and-running-jf-locks"
encrypt = "true"