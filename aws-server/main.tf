
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
    user_data = "${file("userdata.sh")}"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    key_name = "${var.key_name}"
    tags = {
      Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-server-instance"
    # SSH access from anywhere
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow web traffic
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}
