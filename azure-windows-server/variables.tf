variable "prefix" {
  description = "The prefix to be applied to resources"
  default = "demowin"
}
variable resource_group_name {
  default = "tfwindows"
}
variable location {
  default = "northeurope" 
 }
variable tagValue {
  default = "terraform windows demo"
}
 variable computer_name {
   default = "tfwindows"
 }
 variable user_name {
   default = "matt"
 }
 variable password {
 }