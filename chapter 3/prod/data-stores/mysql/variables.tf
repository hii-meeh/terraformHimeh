# prod/data-stores/mysql/variables.tf

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "example_database_prod"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}