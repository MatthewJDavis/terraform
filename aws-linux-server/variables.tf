variable "server_port" {
  description = "The port the server will use for HTTPS requests"
  default = "443"
}
variable "ami" {}
variable "availability_zone" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "region" {}
variable "server_name" {}
variable "iam_instance_profile" {}
