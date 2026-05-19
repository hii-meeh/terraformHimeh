provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami           = "ami-00a9f44477dd83e3d"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /var/www
              echo "Hello, World!" > /var/www/index.html
              cd /var/www
              nohup python3 -m http.server 8080 &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  description = "Security group for Terraform example instance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }
