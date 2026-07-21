# Три одинаковых дополнительных диска по 1 ГБ
resource "yandex_compute_disk" "disks" {
  count = 3

  name = "disk-${count.index + 1}"
  size = 1
  type = "network-hdd"
  zone = var.default_zone
}

# Одиночная ВМ "storage"
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  # Динамическое подключение дополнительных дисков
  dynamic "secondary_disk" {
    for_each = { for idx, disk in yandex_compute_disk.disks : idx => disk }
    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.common_metadata   

  depends_on = [yandex_compute_disk.disks]
}