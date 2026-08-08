provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami                    = "ami-048f644e868baa0e8"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              cd /home/ec2-user
              echo "Hello World, salaam" > index.html
              nohup python3 -m http.server ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the wbe server"
}

resource "aws_key_pair" "deployer" {
  key_name    = "ec2-key"
  public_key  = file("~/.ssh/ec2-key.pub")
}

variable "server_port" {
  description   = "The port the server will use for HTTP requests"
  type          = number
  default       = 8080
}