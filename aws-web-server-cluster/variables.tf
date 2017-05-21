variable "access_key" {}
variable "secret_key" {}
variable "key_name" {
    description = "The key created to allow logon to the server" 
}
variable "server_port"{
    description = "The port the server will use for HTTP requests"
    default = "8080"
}