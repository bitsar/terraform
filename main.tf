provider "aws" {
  region = "ap-southeast-2"
}

# Variables
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

resource "aws_instance" "example" {
  ami = "ami-0b76c3b150c6b1423"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World!" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF

  tags {
    Name ="terraform-example"
    Template = "main.tf"
  }

  #interpolated instance attributes
  #attach SG to instance (set instance parameter)
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

output "public_ip" {
    value = "${aws_instance.example.public_ip}"
}
