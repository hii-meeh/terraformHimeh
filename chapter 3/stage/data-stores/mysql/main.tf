provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  allocated_storage = 10
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "example_database"

  username = var.db_username
  password = var.db_password
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-jf"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-up-and-running-locks-jf"
  }
}