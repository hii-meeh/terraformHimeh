# prod/data-stores/mysql/main.tf

provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-jf"
    key            = "prod/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-up-and-running-locks-jf"
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  publicly_accessible = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
}