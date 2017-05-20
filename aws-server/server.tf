
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "server" {
    ami = "ami-2757f631"
    instance_type = "t2.micro"

    provisioner "local-exec" {
    command = "echo ${aws_instance.server.public_ip} > ip_address.txt"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}
