provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami = "ami-00a9f44477dd83e3d"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-example"
  }
}