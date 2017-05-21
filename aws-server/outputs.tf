output "ami" {
  value = "${lookup(var.amis, var.region)}"
}

output "Public IP" {
    value = "${aws_eip.ip.public_ip}"
}