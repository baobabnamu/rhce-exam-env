locals {
  controller_key = [for k, v in var.vms : k if v.role == "controller"][0]
  utility_key    = [for k, v in var.vms : k if v.role == "utility"][0]
  node_keys      = [for k, v in var.vms : k if v.role == "node"]

  # 인벤토리/출력에 쓸 "대표 IP": networks[0] 기준.
  # controller/utility는 networks[0]이 vmbr0(홈랜) 주소이고, node는 networks[0]이 유일한 격리망(vmbr1) 주소.
  primary_ip = {
    for k, v in var.vms :
    k => split("/", v.networks[0].address)[0]
  }
}

output "controller_ip" {
  description = "Mac/홈랜에서 바로 SSH 가능한 Controller IP"
  value       = local.primary_ip[local.controller_key]
}

output "utility_ip" {
  description = "Mac/홈랜에서 바로 SSH 가능한 Utility IP (내부망 IP는 172.16.0.1 고정)"
  value       = local.primary_ip[local.utility_key]
}

output "node_ips" {
  description = "격리망(vmbr1) IP. Mac에서는 도달 불가 - Controller 안에서만 접근 가능"
  value = {
    for k in local.node_keys :
    k => local.primary_ip[k]
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    controller_name = local.controller_key
    controller_ip    = local.primary_ip[local.controller_key]
    utility_name     = local.utility_key
    utility_ip       = local.primary_ip[local.utility_key]
    nodes = {
      for k in local.node_keys :
      k => local.primary_ip[k]
    }
    ci_user = var.ci_user
  })
}
