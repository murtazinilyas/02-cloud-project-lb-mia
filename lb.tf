data "yandex_compute_instance_group" "cp-ig" {
  instance_group_id = yandex_compute_instance_group.clopro-ig.id
}

resource "yandex_lb_target_group" "clopro_tg" {
  name      = "clopro-tg"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = data.yandex_compute_instance_group.cp-ig.instances
    content {
      subnet_id = yandex_vpc_subnet.clopro_public.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "clopro_nlb" {
  name = "clopro-nlb"

  listener {
    name = "clopro-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.clopro_tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}