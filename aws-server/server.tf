
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}


resource "aws_instance" "server" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"

    provisioner "local-exec" {
    command = "echo ${aws_instance.server.public_ip} > ip_address.txt"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}
