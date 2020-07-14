variable "master-name" {
  type    = string
  default = "example-master"
}

variable "slave-name" {
  type    = string
  default = "example-slave"
}

variable "nlb-name" {
  type    = string
  default = "example-nlb"
}

variable "tg-name" {
  type    = string
  default = "example-target"
}

variable "nlb-listener" {
  type    = string
  default = "example-listener"
}

variable "nlb-storage" {
  type    = string
  default = "example-storage"
}

variable "route-name" {
  type    = string
  default = ""
}
