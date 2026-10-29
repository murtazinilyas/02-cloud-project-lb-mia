resource "yandex_vpc_network" "clopro" {
  name = "clopro-network"
}

resource "yandex_vpc_subnet" "clopro_public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "clopro_private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = yandex_vpc_network.clopro.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat-instance-ip
  }
}