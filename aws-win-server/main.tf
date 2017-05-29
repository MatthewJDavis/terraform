
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}




resource "aws_instance" "server" {
    ami = "ami-f1b5cfe7" #"${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    #user_data = "${file("userdata.sh")}"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    key_name = "${var.key_name}"
    tags {
      Name = "terraform-win-server",
      Terraform = "True"
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-server-instance"
    # SSH access from anywhere
    ingress {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eip" "ip" {
  instance = "${aws_instance.server.id}"
}
