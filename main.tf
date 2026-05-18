provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami = "ami-00a9f44477dd83e3d"
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p 8080 &

  tags = {
    Name = "terraform-example"
  }
}