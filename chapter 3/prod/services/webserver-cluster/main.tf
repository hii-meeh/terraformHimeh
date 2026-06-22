provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "/mnt/d/terraform up and running/chapter 2/chapter 3/modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-jf"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t3.micro"
  min_size      = 2
  max_size      = 10
}