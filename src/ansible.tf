locals {
  webservers = [
    for i in range(length(yandex_compute_instance.web)) : {
      name        = yandex_compute_instance.web[i].name
      external_ip = yandex_compute_instance.web[i].network_interface[0].nat_ip_address
      fqdn        = yandex_compute_instance.web[i].fqdn
    }
  ]
  databases = [
    for vm in yandex_compute_instance.db : {
      name        = vm.name
      external_ip = vm.network_interface[0].nat_ip_address
      fqdn        = vm.fqdn
    }
  ]
  storage = [
    {
      name        = yandex_compute_instance.storage.name
      external_ip = yandex_compute_instance.storage.network_interface[0].nat_ip_address
      fqdn        = yandex_compute_instance.storage.fqdn
    }
  ]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })
  filename = "${path.module}/inventory"
}
