
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

    provisioner "local-exec" {
    command = "echo ${aws_instance.server.public_ip} > ip_address.txt"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}

output "ami" {
  value = "${lookup(var.amis, var.region)}"
}

