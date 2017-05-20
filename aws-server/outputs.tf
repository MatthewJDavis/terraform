output "ami" {
  value = "${lookup(var.amis, var.region)}"
}

output "Public IP" {
    value = "${aws_instance.server.public_ip}"
}