locals {
  controller_key = [for k, v in var.vms : k if v.role == "controller"][0]
  node_keys      = [for k, v in var.vms : k if v.role == "node"]
}

output "controller_ip" {
  value = "${var.ip_prefix_base}.${var.vms[local.controller_key].ip_octet}"
}

output "node_ips" {
  value = {
    for k in local.node_keys :
    k => "${var.ip_prefix_base}.${var.vms[k].ip_octet}"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    controller_name = local.controller_key
    controller_ip    = "${var.ip_prefix_base}.${var.vms[local.controller_key].ip_octet}"
    nodes = {
      for k in local.node_keys :
      k => "${var.ip_prefix_base}.${var.vms[k].ip_octet}"
    }
    ci_user = var.ci_user
  })
}
