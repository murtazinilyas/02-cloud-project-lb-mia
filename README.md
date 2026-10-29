# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»  Муртазин И.А. FOPS-42 SHCLOPRO-30

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашних заданий.

---
## Задание 1. Yandex Cloud 

**Что нужно сделать**

1. Создать бакет Object Storage и разместить в нём файл с картинкой:

 - Создать бакет в Object Storage с произвольным именем (например, _имя_студента_дата_).
 - Положить в бакет файл с картинкой.
 - Сделать файл доступным из интернета.
 
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:

 - Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`.
 - Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata).
 - Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
 - Настроить проверку состояния ВМ.
 
3. Подключить группу к сетевому балансировщику:

 - Создать сетевой балансировщик.
 - Проверить работоспособность, удалив одну или несколько ВМ.

---

## Решение 1.

Манифест `network.tf` оставил без изменений, переписал `main.tf`, написал `lb.tf`.

<details>  
<summary> main.tf </summary>

```hcl
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
```

</details>

<details>  
<summary> lb.tf </summary>

```hcl
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
```
</details>

Закинул картинку в бакет и открыл к ней доступ всем на время.

Поднял получившуюся инфраструктуру и проверил ее работу.

Балансировщик поднялся, машины в инстанс группе прошли хелсчек:

![1](https://github.com/murtazinilyas/02-cloud-project-lb-mia/blob/screenshots/1.png)

Посмотрим как выглядит страница:

![2](https://github.com/murtazinilyas/02-cloud-project-lb-mia/blob/screenshots/2.png)

Эх, суровые реалии поиска работы без опыта в наше время... (;_;)