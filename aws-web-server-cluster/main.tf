provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
 # region     = "${var.region}"
}
data "aws_availability_zones" "all" {}

# Instance config
resource "aws_launch_configuration" "example" {
  image_id = "ami-2d39803a"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = "${file("userdata.sh")}"

  lifecycle {
    create_before_destroy = true
  }
} # end instance config

  # Security group
  resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
   } # end security group

   # Auto scaling group
   resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]

    min_size = 2
    max_size = 10

    load_balancers = ["${aws_elb.example.name}"]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
   }
   # elb security group
   resource "aws_security_group" "elb" {
    name = "terraform-example-elb"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   } # end elb security group

   # elb

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
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }
   } # end elb
