
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

variable "amis" {
  type = "map"
}


resource "aws_instance" "server" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
      Name = "terraform-example"
    }
    user_data = "${file("userdata.sh")}"
  }
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
}

resource "aws_security_group" "instance" {
  name = "terraform-server-instance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}