provider "aws" {
  region = "ap-southeast-2"
}

# Variables and declarations
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "web_port" {
  description = "The port the ELB will use for HTTP requests"
  default = 80
}

data "aws_availability_zones" "all" {}

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

  # interpolated instance attributes
  # attach SG to instance (set instance parameter)
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
}

# Security Groups
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "elb" {
  name ="terraform-example-elb"

  ingress {
    from_port = "${var.web_port}"
    to_port = "${var.web_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0b76c3b150c6b1423"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World!" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 5

  tag {
    key = "Name"
    value ="terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }

  listener {
    lb_port = "${var.web_port}"
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

}

output "public_ip" {
    value = "${aws_instance.example.public_ip}"
}
