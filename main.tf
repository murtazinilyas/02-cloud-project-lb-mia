resource "yandex_compute_instance_group" "clopro-ig" {
  service_account_id  = local.sa_id
  name                = "clopro-ig"
  instance_template {
    platform_id = var.ig-s.platform_id
    resources {
      memory        = var.ig-n.ram
      cores         = var.ig-n.cores
      core_fraction = var.ig-n.core_fraction
    }
    boot_disk {
      initialize_params {
        image_id = var.ig-s.image_id
        size     = var.ig-n.hdd
        type     = var.ig-s.disk_type
      }
    }
    network_interface {
      network_id = yandex_vpc_network.clopro.id
      subnet_ids = [yandex_vpc_subnet.clopro_public.id]
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
    }

      scheduling_policy {
      preemptible = true
    }

  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 0
    max_expansion   = 0
    max_deleting    = 0
  }

}


data template_file "cloudinit" { # Создаем cloud-init файл
  template = file("./cloud-init.yml")

  vars = {
    username           = var.username
    ssh_public_key     = file(var.public_key)
    image_url          = var.image_url
  }
}