provider "aws" {
  region = "${var.region}"
}
resource "aws_instance" "server" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  key_name               = "${var.key_name}"
  availability_zone      = "${var.availability_zone}"
  subnet_id              = "${var.subnet_id}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  tags = {
    Name = "${var.server_name}"
  }
}

resource "aws_security_group" "security_group" {
  name   = "${var.server_name}-sg"
  vpc_id = "${var.vpc_id}"
  # SSH access from 10 network
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  #Allow web traffic
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  #Allow web traffic
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_ip_addr" {
  value = "${aws_instance.server.private_ip}"
}
