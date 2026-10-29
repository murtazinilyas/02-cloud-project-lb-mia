###cloud vars
variable "public_key" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
  description = "Path to public key"
}

variable "username" {
  type    = string
  default = "user"
  description = "Username"
}

variable "zone" {
  default = "ru-central1-e"
}

variable "nat-instance-image-id" {
  default = "fd80mrhj8fl2oe87o4e1"
}

variable "nat-instance-ip" {
  default = "192.168.10.254"
}

variable "ig-n" {
  type = map(number)
  default = {
    cores         = 2
    ram           = 1
    core_fraction = 20
    hdd           = 4
  }
}

variable "ig-s" {
  type = map(string)
  default = {
    platform_id   = "standard-v4a"
    image_id      = "fd827b91d99psvq5fjit"
    disk_type     = "network-hdd"
  }
}

variable "image_url" {
  type    = string
  default = "https://storage.yandexcloud.net/mia-tfstate-bucket/clopro-lb/clopro-pict.webp"
}