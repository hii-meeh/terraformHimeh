provider "aws" {
  region = "us-east-2"
}
resource "aws_launch_template" "example" {
  image_id           = "ami-0fe18bc3cfa53a248"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World!" > /index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  )

  # Required when using a launch confirguration with an auto scaling group.
    lifecycle {
        create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  description = "Security group for Terraform example instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}
output "alb_dns_name" {
    description = "The DNS name of the ALB"
    value = aws_lb.example.dns_name
}
data "aws_vpc" "default" {
 default = true
}
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port              = 80
    protocol          = "HTTP"
    # By defualt, return a simple 404 page
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: Not Found"
            status_code  = "404"
        }
    }
}
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  description = "Security group for Terraform example ALB"

# Allow inbound HTTP traffic from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
#Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  
}