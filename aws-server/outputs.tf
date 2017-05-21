output "ami" {
  value = "${lookup(var.amis, var.region)}"
}

output "public_ip" {
    value = "${aws_eip.ip.public_ip}"
}

output "public_dns" {
    value = "${aws_instance.server.public_dns}"
}